//
//  WDModel.m
//  app
//
//  Created by Joseph Schaffer on 2/9/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDModel.h"

#import "WDConstants.h"

#define WD_EVENT_URL @"http://localhost:3000/api/v0/event?"
#define WD_USER_URL  @"http://localhost:3000/api/v0/user?"



@interface WDModel ()
@property (nonatomic, strong) NSString *userId;
@end

@implementation WDModel

- (id)init {
  self = [super init];
  if (self) {
    
  }
  return self;
}

- (BOOL)hasUserData {
  return self.userId ? YES : NO;
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
  NSDictionary *newUser = @{@"name": name, @"phone":phoneNumber};
  NSDictionary *query   = @{@"user": newUser};
  
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
  [serverConnection start];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
  NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  NSLog(@"Conn: %@, Data: %@", connection, response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"Conn: %@, Error: %@", connection, error);

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSLog(@"Conn: %@", connection);
}

#pragma mark Lazy Initializers

- (NSString *)userId {
  if (!_userId) {
    _userId = [[NSUserDefaults standardUserDefaults] stringForKey:WD_KEY_USER_ID];
  }
  return _userId;
}

@end
