//
//  WDEventVCViewController.m
//  wd
//
//  Created by Joseph Schaffer on 4/20/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDEventVC.h"
#import "WDRootToEventTransition.h"
#import "WDEventDelegate.h"
#import "WDEventDataSource.h"

@interface WDEventVC ()
@property (nonatomic, weak) WDRootToEventTransition *transitionor;

@property (nonatomic, weak) NSObject<WDEventDelegate> *delegate;
@property (nonatomic, weak) NSObject<WDEventDataSource> *dataSource;

@end

@implementation WDEventVC

- (id)initWithTranstionor:(WDRootToEventTransition *)transitionor
                 delegate:(NSObject<WDEventDelegate> *)delegate
               dataSource:(NSObject<WDEventDataSource> *)dataSource {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _dataSource = dataSource;
    _transitionor = transitionor;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.transitioningDelegate = _transitionor;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  
  self.view.backgroundColor = [UIColor blueColor];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
