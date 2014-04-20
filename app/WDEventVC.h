//
//  WDEventVC.h
//  wd
//
//  Created by Joseph Schaffer on 4/20/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDRootToEventTransition;
@protocol WDEventDelegate;
@protocol WDEventDataSource;

@interface WDEventVC : UIViewController

- (id)initWithTranstionor:(WDRootToEventTransition *)transitionor
                 delegate:(NSObject<WDEventDelegate> *)delegate
               dataSource:(NSObject<WDEventDataSource> *)dataSource;

@end
