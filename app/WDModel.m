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

#define WD_EVENT_URL @"http://localhost:3000/api/v0/event?"
#define WD_USER_URL  @"http://localhost:3000/api/v0/user?"



@interface WDModel ()
@property NSObject<WDModelDelegate> *delegate;
@property WDInteractionMode mode;
@property (nonatomic, strong) NSString *userId;
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
  return NO;
//  return self.userId ? YES : NO;
}

- (BOOL)verifyUserWithCode:(NSString *)code {
  NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:WD_localKey_User_object];
  NSLog(@"code: %@, localCode: %@", code, [user objectForKey:WD_modelKey_User_verifyCode]);
  NSNumber *verifyCode = [user objectForKey:WD_modelKey_User_verifyCode];
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  formatter.numberStyle = NSNumberFormatterDecimalStyle;
  NSNumber *codeNum = [formatter numberFromString:code];
  
  if ([codeNum isEqualToNumber:verifyCode]) {
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:WD_modelKey_User_id]
                                              forKey:WD_localKey_User_id];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark Button Method

- (void)didTapOnTest {
  [self testServer];
}

#pragma mark WDVerifyDelegate Methods

- (void)verifyUserWithName:(NSString *)name phoneNumber:(NSNumber *)phoneNumber {
  NSDictionary *newUser = @{WD_modelKey_User_name: name, WD_modelKey_User_phone:phoneNumber};
  NSDictionary *query   = @{WD_modelKey_User: newUser};
  
  NSData *postData = [NSJSONSerialization dataWithJSONObject:query
                                                 options:0
                                                   error:nil];
  NSURL *url = [NSURL URLWithString:WD_USER_URL];
  
  NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:postData];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  
  self.mode = WDInteractionVerify;
  [serverConnection start];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
    case WDInteractionVerify:
      [[NSUserDefaults standardUserDefaults] setObject:responseData forKey:WD_localKey_User_object];
      [[NSUserDefaults standardUserDefaults] synchronize];
      break;
    default:
      break;
  }
  
  NSLog(@"URL: %@, Data: %@", connection.currentRequest.URL, response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  self.mode = WDInteractionNone;
  NSLog(@"Conn: %@, Error: %@", connection, error);

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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

@end
