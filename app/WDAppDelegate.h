//
//  WDAppDelegate.h
//  app
//
//  Created by Joseph Schaffer on 2/9/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDRootVC;

@interface WDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WDRootVC *rootVC;

@end
