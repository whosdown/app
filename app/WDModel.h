//
//  WDModel.h
//  app
//
//  Created by Joseph Schaffer on 1/25/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDModel : NSObject<NSURLConnectionDataDelegate>

- (void)postEventWithMessage:(NSString *)message;

@end
