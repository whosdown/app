//
//  WDRootVC.m
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDRootVC.h"

#import "WDComposeVC.h"
#import "WDEventsVC.h"
#import "WDModel.h"
#import "WDVerifyVC.h"

@interface WDRootVC ()
@property WDModel *model;
@property (nonatomic, strong) WDVerifyVC *verifyVC;
@property (nonatomic, strong) WDEventsVC *eventsVC;
@property (nonatomic, strong) WDComposeVC *composeVC;
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
  
  self.composeVC = [[WDComposeVC alloc] initWithNibName:nil bundle:nil];
  self.eventsVC = [[WDEventsVC alloc] initWithStyle:UITableViewStylePlain];
  
  if (self.model.hasUserLoggedIn) {
    
  } else {
    self.verifyVC = [[WDVerifyVC alloc] initWithDelegate:self.model];
    [self displayInnerViewController:self.verifyVC withFrame:self.view.frame];
  }
}

- (void)verifyUserWithCode:(NSString *)code {
  if (self.model.hasUserLoggedIn) {
    // TODO: You're trying to verify an already active user
  } else {
    if (!self.verifyVC) {
      NSLog(@"Went to conclude Verify, but not displaying WDVerifyVC");
      return;
    }

    if ([self.model verifyUserWithCode:code]) {
      // TODO: Swap to main events VC
      NSLog(@"User Is Verified: %@", self.model.hasUserLoggedIn ? @"YES" : @"NO");
      [self.verifyVC verifyDidSucceed];
      
    } else {
      [self.verifyVC verifyDidFail];
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
      if (!self.verifyVC) {
        NSLog(@"Received Data for Verify, but not displaying WDVerifyVC");
        return;
      }
      [self.verifyVC verifyDidInitiate];
      return;
    } default:
      break;
  }
}

- (void)didReceiveError:(NSError *)error fromInteractionMode:(WDInteractionMode)mode{
  
}

#pragma mark Child View Management

- (void) displayInnerViewController:(UIViewController*)innerVC withFrame:(CGRect)frame {
  [self addChildViewController:innerVC];
  innerVC.view.frame = frame;
  [self.view addSubview:innerVC.view];
  [innerVC didMoveToParentViewController:self];
}

- (void) hideInnerViewController {
  UIViewController *viewControllerToRemove = [[self childViewControllers] firstObject];
  [viewControllerToRemove willMoveToParentViewController:nil];
  [viewControllerToRemove.view removeFromSuperview];
  [viewControllerToRemove removeFromParentViewController];
}

@end
