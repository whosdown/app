//
//  WDVerifyVC.m
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDVerifyVC.h"

#import "WDVerifyDelegate.h"

@interface WDVerifyVC ()
@property NSObject<WDVerifyDelegate> *delegate;
@end

@implementation WDVerifyVC

- (id)initWithDelegate:(NSObject<WDVerifyDelegate> *)delegate {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _delegate = delegate;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
	
  self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)verifyDidInitiate {
  
}

- (void)verifyDidSucceed {
  
}

@end
