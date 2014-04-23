//
//  WDEventDataSource.h
//  wd
//
//  Created by Joseph Schaffer on 4/20/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDEventDataSource <NSObject>

- (void)refreshMessagesFromCurrentEventOnSuccess:(void (^)(void))success
                                       onFailure:(void (^)(void))failure;

- (NSDictionary *)event;

- (void)setCurrentEvent:(NSDictionary *)currentEvent;

- (void)updateRecipient:(NSDictionary *)recipient;

- (NSArray *)messages;

@end
