//
//  WDRootToEventTransition.m
//  wd
//
//  Created by Joseph Schaffer on 4/20/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDRootToEventTransition.h"

@interface WDRootToEventTransition ()

@property BOOL presenting;
@property CGPoint originalTopCenter;
@property CGPoint originalBottomCenter;

@property (nonatomic, weak) UIViewController *eventVC;
@property (nonatomic, weak) UIViewController *rootVC;

@property (strong, nonatomic) UIPercentDrivenInteractiveTransition* interactionController;

@end

@implementation WDRootToEventTransition

- (void)pan:(UIPanGestureRecognizer*)recognizer {
  UIView* view = self.eventVC.view;
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    CGPoint location = [recognizer locationInView:view];
    if (location.x <  CGRectGetMidX(view.frame)) { // left half
      self.interactionController = [UIPercentDrivenInteractiveTransition new];
      [self.rootVC dismissViewControllerAnimated:YES completion:nil];
    }
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGPoint translation = [recognizer translationInView:view];
    CGFloat d = fabs(translation.x / CGRectGetWidth(view.frame));
    [self.interactionController updateInteractiveTransition:d];
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    if ([recognizer velocityInView:view].x > 0) {
      [self.interactionController finishInteractiveTransition];
    } else {
      [self.interactionController cancelInteractiveTransition];
    }
    self.interactionController = nil;
  }
}

#pragma mark UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented
                         presentingController:(UIViewController *)presenting
                             sourceController:(UIViewController *)source {
  self.presenting = YES;
//  self.eventVC = presenting;
//  self.rootVC  = source;
  
//  UIPanGestureRecognizer* panRecognizer =
//      [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//  [presenting.view addGestureRecognizer:panRecognizer];
  
  return self;
}

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed {
  self.presenting = NO;
  return self;
}

#pragma mark UIViewControllerAnimatedTransitioning Methods

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  if (self.presenting) {
    self.originalTopCenter    = self.top.view.center;
    self.originalBottomCenter = self.bottom.view.center;

    [self executePresentationAnimation:transitionContext];
  } else {
    [self executeDismissalAnimation:transitionContext];
  }
}

- (void)executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *fromViewController =
      [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController   =
      [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  [[transitionContext containerView] insertSubview:toViewController.view
                                      belowSubview:fromViewController.view];
  
  CGPoint topEndCenter    = self.top.view.center;
  CGPoint bottomEndCenter = self.bottom.view.center;
  topEndCenter.y    = (-1) * self.top.view.center.y;
  bottomEndCenter.y = self.bottom.view.center.y + self.bottom.view.frame.size.height;
  
  [UIView animateWithDuration:[self transitionDuration:transitionContext]
                   animations:^{
                     self.top.view.center    = topEndCenter;
                     self.bottom.view.center = bottomEndCenter;
                   } completion:^(BOOL finished) {
                     [[transitionContext containerView] sendSubviewToBack:fromViewController.view];
                     [transitionContext
                         completeTransition:![transitionContext transitionWasCancelled]];
                   }];
}

- (void)executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *toViewController   =
      [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  [[transitionContext containerView] addSubview:toViewController.view];
  
  [UIView animateWithDuration:[self transitionDuration:transitionContext]
                   animations:^{
                     self.top.view.center    = self.originalTopCenter;
                     self.bottom.view.center = self.originalBottomCenter;
                   } completion:^(BOOL finished) {
                     self.eventVC = nil;
                     self.rootVC  = nil;
                     [transitionContext
                         completeTransition:![transitionContext transitionWasCancelled]];
                   }];
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.5;
}

@end
