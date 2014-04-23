//
//  WDInviteesVC.h
//  wd
//
//  Created by Joseph Schaffer on 4/23/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDEventVC;
@protocol WDEventDataSource;

@interface WDInviteesVC : UINavigationController<UITableViewDataSource,
                                                 UITableViewDelegate>


- (id)initWithDataSource:(NSObject<WDEventDataSource> *)dataSource;

- (void)refreshSets;

@property (nonatomic, strong) WDEventVC *parent;

@end
