//
//  WDComposeVC.h
//  wd
//
//  Created by Joseph Schaffer on 3/6/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDComposeDataSource;
@protocol WDComposeDelegate;

@interface WDComposeVC : UIViewController<UITextFieldDelegate>

- (id)initWithFrame:(CGRect)frame
           delegate:(NSObject<WDComposeDelegate> *)delegate
         dataSource:(NSObject<WDComposeDataSource> *)dataSource;

@end
