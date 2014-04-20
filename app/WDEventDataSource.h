//
//  WDEventDataSource.h
//  wd
//
//  Created by Joseph Schaffer on 4/20/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDEventDataSource <NSObject>

- (void)refreshMessagesFromEvent:(NSDictionary *)event
                       onSuccess:(void (^)(void))success
                       onFailure:(void (^)(void))failure;

- (NSDictionary *)event;

- (NSArray *)messages;

@end
