//
//  WDRootVC.h
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WDModelDelegate.h"
#import "WDEventDelegate.h"
#import "WDEventsDelegate.h"

@interface WDRootVC : UINavigationController<WDModelDelegate,
                                             WDEventDelegate,
                                             WDEventsDelegate>

- (void)verifyUserWithCode:(NSString *)code;

@end
