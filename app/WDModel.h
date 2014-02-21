//
//  WDModel.h
//  app
//
//  Created by Joseph Schaffer on 2/9/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WDVerifyDelegate.h"

@interface WDModel : NSObject<NSURLConnectionDelegate, WDVerifyDelegate>

// Must be checked to proceed to use WDModel.
// Returns YES if the model has a user and can use that to communicate with the server.
- (BOOL)hasUserData;

- (void)testServer;

- (void)didTapOnTest;
@end
