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
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UITextField *peopleField;
@property (nonatomic, strong) UITextField *messageField;
@property (nonatomic, strong) UIToolbar *backgroundBar;
@property (nonatomic, strong) UIView *fieldDivider;

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
  
//  self.view.backgroundColor = WD_UIColor_green;
  
  
  CGFloat viewWidth = self.view.bounds.size.width;
  CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  CGFloat gridSize = (self.contentFrame.size.height - statusHeight) / 5;

  
  CGFloat offset = 20;
  CGFloat fieldSpacer = 7;
  
  CGFloat titleRegionHeight = gridSize * 2;
  CGFloat fieldRegionHeight = gridSize * 3;
  CGPoint fieldRegionCenter =
      CGPointMake((viewWidth / 2), statusHeight + titleRegionHeight + (fieldRegionHeight / 2));
  
  CGRect peopleFieldRect = CGRectMake(self.peopleField.frame.origin.x,
                                      self.peopleField.frame.origin.y,
                                      viewWidth - (2 * offset),
                                      self.peopleField.frame.size.height);
  CGRect messageFieldRect = CGRectMake(self.messageField.frame.origin.x,
                                       self.messageField.frame.origin.y,
                                       viewWidth - (2 * offset),
                                       self.messageField.frame.size.height);
  CGRect fieldDividerRect = CGRectMake(0,
                                       0,
                                       messageFieldRect.size.width,
                                       1 / [[UIScreen mainScreen] scale]);

  
  self.backgroundBar.frame = self.contentFrame;
  self.heading.center = CGPointMake((viewWidth / 2), statusHeight + (titleRegionHeight / 2));
  self.peopleField.frame  = peopleFieldRect;
  self.peopleField.center =
      CGPointMake(fieldRegionCenter.x,
                  fieldRegionCenter.y - (self.peopleField.frame.size.height / 2) - fieldSpacer);
  self.messageField.frame = messageFieldRect;
  self.messageField.center =
      CGPointMake(fieldRegionCenter.x,
                  fieldRegionCenter.y + (self.messageField.frame.size.height / 2) + fieldSpacer);
  self.fieldDivider.frame = fieldDividerRect;
  self.fieldDivider.center = fieldRegionCenter;

  [self.view addSubview:self.backgroundBar];
  [self.view addSubview:self.heading];
  [self.view addSubview:self.peopleField];
  [self.view addSubview:self.messageField];
  [self.view addSubview:self.fieldDivider];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Lazy Initializers

- (UILabel *)heading {
  if (!_heading) {
    _heading = [[UILabel alloc] init];
    _heading.text = WD_comp_title;
    _heading.textAlignment = NSTextAlignmentCenter;
    _heading.textColor = [UIColor whiteColor];
    _heading.font = [UIFont fontWithName:WD_comp_titleFont size:WD_comp_titleSize];
    [_heading sizeToFit];
  }
  return _heading;
}

- (UIToolbar *)backgroundBar {
  if (!_backgroundBar) {
    _backgroundBar = [[UIToolbar alloc] init];
    _backgroundBar.barTintColor = WD_UIColor_green;
    _backgroundBar.translucent = YES;
//    _backgroundBar.contentMode =
  }
  return _backgroundBar;
}

- (UITextField *)peopleField {
  if (!_peopleField) {
    _peopleField = [[UITextField alloc] init];
    _peopleField.textAlignment = NSTextAlignmentLeft;
    _peopleField.textColor = [UIColor whiteColor];
    _peopleField.font = [UIFont fontWithName:WD_comp_fieldFont size:WD_comp_fieldSize];
    _peopleField.placeholder = WD_comp_peopleFieldPlaceholder;
    _peopleField.returnKeyType = UIReturnKeyDone;
    [_peopleField sizeToFit];
    
    _peopleField.delegate = self;
  }
  return _peopleField;
}

- (UITextField *)messageField {
  if (!_messageField) {
    _messageField = [[UITextField alloc] init];
    _messageField.textAlignment = NSTextAlignmentLeft;
    _messageField.textColor = [UIColor whiteColor];
    _messageField.font = [UIFont fontWithName:WD_comp_fieldFont size:WD_comp_fieldSize];
    _messageField.placeholder = WD_comp_messageFieldPlaceholder;
    _messageField.returnKeyType = UIReturnKeyDone;
    [_messageField sizeToFit];
    
    _messageField.delegate = self;
  }
  return _messageField;
}

- (UIView *)fieldDivider {
  if (!_fieldDivider) {
    _fieldDivider = [[UIView alloc] init];
    _fieldDivider.backgroundColor = [UIColor grayColor];
  }
  return _fieldDivider;
}


@end
