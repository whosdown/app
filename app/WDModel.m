//
//  WDModel.m
//  app
//
//  Created by Joseph Schaffer on 1/25/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDModel.h"

#define WD_URL_PREFIX @"http://10.0.0.62:3000/api/"
#define WD_EVENT @"event?"

#define APP_PN @"6467852201"


@implementation WDModel

- (void)postEventWithMessage:(NSString *)message {
  NSString *url = [NSString stringWithFormat:@"&id=%@&msg=%@",
                   APP_PN,
                   message];
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
  NSURLConnection *serverConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  [serverConnection start];
}

@end
