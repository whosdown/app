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
#import "WDEventVC.h"
#import "WDModel.h"
#import "WDVerifyVC.h"
#import "WDRootToEventTransition.h"

@interface WDRootVC ()
@property WDModel *model;
@property (nonatomic, strong) WDVerifyVC *verifyVC;
@property (nonatomic, strong) WDEventsVC *eventsVC;
@property (nonatomic, strong) WDComposeVC *composeVC;
@property (nonatomic, strong) WDRootToEventTransition *transitionor;
@property (nonatomic, strong) WDEventVC *eventVC;
@end

@implementation WDRootVC

- (id)init {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _model = [[WDModel alloc] initWithDelegate:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  
  self.view.backgroundColor = [UIColor clearColor];
  // TODO: Switch to designated Initializer
  [self setNavigationBarHidden:YES];

  
  if (self.model.hasUserLoggedIn) {
    [self displayDefaultUI];
  } else {
    self.verifyVC = [[WDVerifyVC alloc] initWithDelegate:self.model];
    [self displayInnerViewController:self.verifyVC withFrame:self.view.frame];
  }
  
  self.transitionor = [[WDRootToEventTransition alloc] init];
  self.transitionor.top = self.composeVC;
  self.transitionor.bottom = self.eventsVC;
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
      NSLog(@"User Is Verified: %@", self.model.hasUserLoggedIn ? @"YES" : @"NO");
      [self.verifyVC verifyDidSucceed];
      [self hideInnerViewController:self.verifyVC];
      
      [self displayDefaultUI];
      self.verifyVC = nil;
    } else {
      [self.verifyVC verifyDidFail];
    }
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayDefaultUI {
  CGFloat gridSize = 44;
  CGRect composeRect = self.view.frame;
  composeRect.size.height = gridSize * 3;

  self.composeVC.halfScreenFrame = composeRect;
  self.eventsVC.tableView.contentInset = UIEdgeInsetsMake(composeRect.size.height, 0, 0, 0);

  [self displayInnerViewController:self.eventsVC withFrame:self.view.frame];
  [self displayInnerViewController:self.composeVC withFrame:composeRect];
}

#pragma mark WDEventDelegate Methods

- (void)didTapOnCancelButton {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark WDEventsDelegate Methods

- (void)didTapOnEvent:(NSDictionary *)event {
  self.model.currentEvent = event;
  self.eventVC = [[WDEventVC alloc] initWithTranstionor:self.transitionor
                                               delegate:self
                                             dataSource:self.model];
  [self presentViewController:self.eventVC
                     animated:YES
                   completion:^{
                     
                   }];
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
    }
    case WDInteractionCreateEvent:
      [self.composeVC composeDidSucceed];
      [self.eventsVC.tableView reloadData];
      break;
    default:
      break;
  }
}

- (void)didReceiveError:(NSError *)error fromInteractionMode:(WDInteractionMode)mode{
  switch (mode) {
    case WDInteractionVerify:
      [self.verifyVC verifyDidFail];
      break;
    case WDInteractionCreateEvent:
      [self.composeVC composeDidFail];
      break;
    default:
      break;
  }

}

- (void)didFinishFromInteractionMode:(WDInteractionMode)mode {
  
}


#pragma mark Child View Management

- (void) displayInnerViewController:(UIViewController *)innerVC withFrame:(CGRect)frame {
  [self addChildViewController:innerVC];
  innerVC.view.frame = frame;
  [self.view addSubview:innerVC.view];
  [innerVC didMoveToParentViewController:self];
}

- (void) hideInnerViewController:(UIViewController *)innerVC {
//  UIViewController *viewControllerToRemove = [[self childViewControllers] firstObject];
  [innerVC willMoveToParentViewController:nil];
  [innerVC.view removeFromSuperview];
  [innerVC removeFromParentViewController];
}

#pragma mark Lazy Initializers

- (WDEventsVC *)eventsVC {
  if (!_eventsVC) {
    _eventsVC = [[WDEventsVC alloc] initWithDelegate:self
                                      withDataSource:self.model];
  }
  return _eventsVC;
}

- (WDComposeVC *)composeVC {
  if (!_composeVC) {
    _composeVC = [[WDComposeVC alloc] initWithDelegate:self.model dataSource:nil];
  }
  return _composeVC;
}

@end
