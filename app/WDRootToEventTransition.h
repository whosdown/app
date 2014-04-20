//
//  WDRootToEventTransition.h
//  wd
//
//  Created by Joseph Schaffer on 4/20/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDRootToEventTransition : NSObject <UIViewControllerTransitioningDelegate,
                                               UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) UIViewController *top;
@property (nonatomic, weak) UIViewController *bottom;

@end
