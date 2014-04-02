//
//  WDComposeDelegate.h
//  wd
//
//  Created by Joseph Schaffer on 3/6/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDComposeDelegate <NSObject>

- (void)createEventWithPeople:(NSArray *)people message:(NSString *)message;

@end
