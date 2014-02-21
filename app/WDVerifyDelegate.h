//
//  WDVerifyDelegate.h
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDVerifyDelegate <NSObject>

- (void)verifyUserWithName:(NSString *)name phoneNumber:(NSNumber *)phoneNumber;

@end