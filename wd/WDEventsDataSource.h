//
//  WDEventsDataSource.h
//  wd
//
//  Created by Joseph Schaffer on 4/3/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDEventsDataSource <NSObject>

- (void)refreshEventsOnSuccess:(void (^)(void))success onFailure:(void (^)(void))failure;

- (BOOL)isRefreshing;

- (NSArray *)events;

@end
