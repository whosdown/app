//
//  WDEventsVC.h
//  wd
//
//  Created by Joseph Schaffer on 3/6/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDEventsDelegate;

@interface WDEventsVC : UITableViewController

- (id)initWithDelegate:(NSObject<WDEventsDelegate> *)delegate viewInset:(UIEdgeInsets)inset;

@end
