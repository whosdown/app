//
//  WDComposeVC.m
//  wd
//
//  Created by Joseph Schaffer on 3/6/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDComposeVC.h"
#import "WDComposeDataSource.h"
#import "WDComposeDelegate.h"
#import "WDConstants.h"


@interface WDComposeVC ()
@property (nonatomic, strong) UILabel *heading;

@property NSObject<WDComposeDataSource> *dataSource;
@property NSObject<WDComposeDelegate> *delegate;
@property CGRect contentFrame;

@property (nonatomic, strong) UITextField *peopleField;
@property (nonatomic, strong) UITextField *messageField;

@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation WDComposeVC

- (id)initWithFrame:(CGRect)frame
           delegate:(NSObject<WDComposeDelegate> *)delegate
         dataSource:(NSObject<WDComposeDataSource> *)dataSource {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _dataSource = dataSource;
    _delegate = delegate;
    _contentFrame = frame;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
//  UIToolbar *test = [[UIToolbar alloc] initWithFrame:self.view.bounds];
//  test.barTintColor = WD_UIColor_green;
//  
//  [self.view addSubview:test];
  
  self.view.backgroundColor = WD_UIColor_green;
  
  
  CGFloat viewWidth = self.view.bounds.size.width;
  CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  CGFloat gridSize = (self.contentFrame.size.height - statusHeight) / 5;

  self.heading.center = CGPointMake((viewWidth / 2), statusHeight + ((gridSize * 2) / 2));
  
  [self.view addSubview:self.heading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Lazy Initializers

- (UILabel *)heading {
  if (!_heading) {
    _heading = [[UILabel alloc] init];
    _heading.text = WD_TITLE;
    _heading.textAlignment = NSTextAlignmentCenter;
    _heading.textColor = [UIColor whiteColor];
    _heading.font = [UIFont fontWithName:WD_TITLE_FONT size:WD_comp_title_size];
    [_heading sizeToFit];
  }
  return _heading;
}

@end
