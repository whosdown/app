//
//  WDRootVC.m
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDRootVC.h"

#import "WDModel.h"
#import "WDVerifyVC.h"

@interface WDRootVC ()
@property WDModel *model;
@property (nonatomic, strong) UIViewController *currentViewController;
@end

@implementation WDRootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _model = [[WDModel alloc] initWithDelegate:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (self.model.hasUserLoggedIn) {
    // TODO: Main Events VC
    self.view.backgroundColor = [UIColor blueColor];
  } else {    
    [self displayInnerViewController:[[WDVerifyVC alloc] initWithDelegate:self.model]];
  }
}

- (void)verifyUserWithCode:(NSString *)code {
  if (self.model.hasUserLoggedIn) {
    // TODO: You're trying to verify an already active user
  } else {
    if ([self.model verifyUserWithCode:code]) {
      // TODO: Swap to main events VC
      NSLog(@"User Is Verified: %@", self.model.hasUserLoggedIn ? @"YES" : @"NO");
      
    } else {
      if (![self.currentViewController isKindOfClass:[WDVerifyVC class]]) {
        NSLog(@"Went to conclude Verify, but not displaying WDVerifyVC");
        return;
      }
      WDVerifyVC *verifyVC = (WDVerifyVC *)self.currentViewController;
      [verifyVC verifyDidInitiate];
    }
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark WDModelDelegate Methods

- (void)didReceiveData:(NSDictionary *)data fromInteractionMode:(WDInteractionMode)mode {
  switch (mode) {
    case WDInteractionVerify: {
      if (![self.currentViewController isKindOfClass:[WDVerifyVC class]]) {
        NSLog(@"Received Data for Verify, but not displaying WDVerifyVC");
        return;
      }
      WDVerifyVC *verifyVC = (WDVerifyVC *)self.currentViewController;
      [verifyVC verifyDidInitiate];
      return;
    } default:
      break;
  }
}

- (void)didReceiveError:(NSError *)error fromInteractionMode:(WDInteractionMode)mode{
  
}

#pragma mark Child View Management

- (void) displayInnerViewController: (UIViewController*) innerVC {
  [self addChildViewController:innerVC];
  innerVC.view.frame = self.view.frame;
  [self.view addSubview:innerVC.view];
  [innerVC didMoveToParentViewController:self];
  self.currentViewController = innerVC;
}

- (void) hideInnerViewController {
  UIViewController *viewControllerToRemove = [[self childViewControllers] firstObject];
  [viewControllerToRemove willMoveToParentViewController:nil];
  [viewControllerToRemove.view removeFromSuperview];
  [viewControllerToRemove removeFromParentViewController];
  self.currentViewController = nil;
}

@end
