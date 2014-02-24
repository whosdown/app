//
//  WDVerifyVC.h
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDVerifyDelegate;

@interface WDVerifyVC : UIViewController<UITextFieldDelegate>

// Designated Initializer
- (id)initWithDelegate:(NSObject<WDVerifyDelegate> *)delegate;

- (void)verifyDidInitiate;

- (void)verifyDidSucceed;

@end
