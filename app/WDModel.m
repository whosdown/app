//
//  WDModel.m
//  app
//
//  Created by Joseph Schaffer on 1/25/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDModel.h"

#define WD_URL_PREFIX @"http://174.141.145.78:3000/api/"
#define WD_EVENT @"event?"

#define APP_PN @"+16467852201"


@implementation WDModel

- (void)postEventWithMessage:(NSString *)message {
  NSString *url = [NSString stringWithFormat:@"%@%@&crtr=%@&msg=%@",
                   WD_URL_PREFIX,
                   WD_EVENT,
                   APP_PN,
                   message];
  NSLog(@"%@",url);
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
  [request setHTTPMethod:@"POST"];
  NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request
                                                                      delegate:self];
  
  [serverConnection start];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
}
  
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                  message:@"Unable to connect with server."
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
