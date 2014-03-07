//
//  WDComposeVC.m
//  wd
//
//  Created by Joseph Schaffer on 3/6/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDComposeVC.h"

#import "WDConstants.h"

@interface WDComposeVC ()

@end

@implementation WDComposeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = WD_UIColor_green;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
