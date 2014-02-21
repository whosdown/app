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
    _model = [[WDModel alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (self.model.hasUserData) {
    // TODO: Main Events VC
    self.view.backgroundColor = [UIColor blueColor];
  } else {
    self.view.backgroundColor = [UIColor greenColor];
    
    [self displayInnerViewController:[[WDVerifyVC alloc] initWithDelegate:self.model]];
  }
}



//- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
//  return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Child View Management

- (void) displayInnerViewController: (UIViewController*) innerVC {
  [self addChildViewController:innerVC];
  innerVC.view.frame = self.view.frame;
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
