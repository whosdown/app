//
//  WDModel.m
//  app
//
//  Created by Joseph Schaffer on 2/9/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDModel.h"

#import "WDConstants.h"
#import "WDModelDelegate.h"

#define WD_EVENT_URL  WD_URL @"/api/v0/event?"
#define WD_USER_URL   WD_URL @"/api/v0/user?"
#define WD_VERIFY_URL WD_URL @"/api/v0/verify?"

#define POST @"POST"
#define GET  @"GET"

typedef void (^voidBlock)(void);

@interface WDModel ()
@property NSObject<WDModelDelegate> *delegate;
@property WDInteractionMode mode;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, strong) voidBlock completion;
@end

@implementation WDModel

- (id)initWithDelegate:(NSObject<WDModelDelegate> *)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _mode = WDInteractionNone;
  }
  return self;
}

- (BOOL)hasUserLoggedIn {
  return self.userId ? YES : NO;
}

- (BOOL)verifyUserWithCode:(NSString *)code {
  NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:WD_localKey_User_object];
  if (!user || !code) {
    // TODO: Nothing to verify, try again.
    return NO;
  }
  NSNumber *verifyCode = [user objectForKey:WD_modelKey_User_verifyCode];
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  formatter.numberStyle = NSNumberFormatterDecimalStyle;
  NSNumber *codeNum = [formatter numberFromString:code];
  
  NSLog(@"code: %@, localCode: %@", codeNum, verifyCode);

  if ([codeNum isEqualToNumber:verifyCode]) {
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:WD_modelKey_User_id]
                                              forKey:WD_localKey_User_id];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *query   = @{WD_modelKey_Verify_code: code,
                              WD_modelKey_Verify_id  : [user objectForKey:WD_modelKey_User_id]};
    
    [self sendMethod:POST
               toURL:WD_VERIFY_URL
      withDictionary:query
              inMode:WDInteractionVerifyConclude];
    
    return YES;
  } else {
    return NO;
  }
}

- (void)testServer {
  NSDictionary *entryA = @{@"name": @"Joe", @"phone": @1112223333};
  NSDictionary *entryB = @{@"name": @"Bob", @"phone": @1112224444};
  NSDictionary *query  = @{@"recips" : @[entryA, entryB],
                           @"message": @"Y'all down??",
                           @"userId" : @"52f6b6d3c9c3d24c2f068802"};

  NSData *data = [NSJSONSerialization dataWithJSONObject:query
                                                 options:0
                                                   error:nil];
  NSURL *url = [NSURL URLWithString:WD_EVENT_URL];
  
  NSData *postData = data;
//    [NSMutableData dataWithData:[post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
//  [postData setValue:@"test" forKey:@"recips"];
  NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
  
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:postData];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  [serverConnection start];
}

- (void)sendMethod:(NSString *)method
             toURL:(NSString *)urlString
    withDictionary:(NSDictionary *)dict
            inMode:(WDInteractionMode)mode {

  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:method];

  if ([method isEqualToString:POST]) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *dataLength = [NSString stringWithFormat:@"%d",[data length]];
    [request setHTTPBody:data];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  } else if ([method isEqualToString:GET]) {
    NSMutableString *queryString = [NSMutableString stringWithString:urlString];
    for (NSString *key in dict) {
      [queryString appendFormat:@"&%@=%@", key, [dict objectForKey:key]];
    }
    [request setURL:[NSURL URLWithString:queryString]];
  }
  
  NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request
                                                                      delegate:self];
  self.mode = mode;
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  [serverConnection start];
}

#pragma mark Button Method

- (void)didTapOnTest {
  [self testServer];
}

#pragma mark WDVerifyDelegate Methods

- (void)verifyUserWithName:(NSString *)name phoneNumber:(NSString *)phoneNumber {
  NSString *USPhoneNumber = [NSString stringWithFormat:@"+1%@", phoneNumber];
  NSDictionary *query = @{ WD_modelKey_User : @{
                               WD_modelKey_User_name  : name,
                               WD_modelKey_User_phone : USPhoneNumber
                             }
                          };

  [self sendMethod:POST toURL:WD_USER_URL withDictionary:query inMode:WDInteractionVerify];
}

#pragma mark WDComposeDelegate Methods

- (void)createEventWithPeople:(NSArray *)people message:(NSString *)message{
  NSDictionary *data = @{ WD_modelKey_Event_userId  : self.userId,
                          WD_modelKey_Event_message : message,
                          WD_modelKey_Event_recips  : people };
  NSLog(@" data: %@", data);
  [self sendMethod:POST toURL:WD_EVENT_URL withDictionary:data inMode:WDInteractionCreateEvent];
}

#pragma mark WDEventsDataSource Methods

- (void)refreshEvents:(void (^)(void))completed {
  self.completion = completed;

  [self.events removeAllObjects];
  [self sendMethod:GET
             toURL:WD_EVENT_URL
    withDictionary:@{ WD_modelKey_Event_userId : self.userId }
            inMode:WDInteractionGetEvents];
}

- (BOOL)isRefreshing {
  return self.mode == WDInteractionGetEvents;
}

#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
  NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
  
  NSDictionary *responseData = [response objectForKey:WD_modelKey_SUCCESS_DATA];
  if (!responseData) {
    NSError *error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork
                                         code:[[response objectForKey:@"status"] intValue]
                                     userInfo:[response objectForKey:WD_modelKey_FAILURE_DATA]];
    [self.delegate didReceiveError:error fromInteractionMode:self.mode];
    return;
  }
  
  [self.delegate didReceiveData:responseData fromInteractionMode:self.mode];
  
  switch (self.mode) {
    case WDInteractionVerify: {
      [[NSUserDefaults standardUserDefaults] setObject:responseData forKey:WD_localKey_User_object];
      [[NSUserDefaults standardUserDefaults] synchronize];
      break;
    }
    case WDInteractionGetEvents: {
      for (NSDictionary *event in responseData) {
        [self.events addObject:event];
      }
      voidBlock complete = self.completion;
      complete();
      break;
    }
      
    default:
      break;
  }
  
  [self.delegate didReceiveData:responseData fromInteractionMode:self.mode];
  
//  NSLog(@"URL: %@, Data: %@", connection.currentRequest.URL, response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  [self.delegate didReceiveError:error fromInteractionMode:self.mode];
  self.mode = WDInteractionNone;
  NSLog(@"Conn: %@, Error: %@", connection, error);

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  [self.delegate didFinishFromInteractionMode:self.mode];
  self.mode = WDInteractionNone;
  NSLog(@"Conn: %@", connection);
}

#pragma mark Lazy Initializers

- (NSString *)userId {
  if (!_userId) {
    _userId = [[NSUserDefaults standardUserDefaults] stringForKey:WD_localKey_User_id];
  }
  return _userId;
}

- (NSMutableArray *)events {
  if (!_events) {
    _events = [[NSMutableArray alloc] init];
  }
  return _events;
}

@end
