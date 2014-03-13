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

@property BOOL isFullScreen;
@property NSObject<WDComposeDataSource> *dataSource;
@property NSObject<WDComposeDelegate> *delegate;
@property CGRect contentFrame;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UINavigationBar *navBar;
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
  
  self.isFullScreen = false;
  
  [self setFrame:self.contentFrame inFullScreenMode:NO];

  [self.view addSubview:self.backgroundBar];
  [self.view addSubview:self.heading];
  [self.view addSubview:self.peopleField];
  [self.view addSubview:self.messageField];
  [self.view addSubview:self.fieldDivider];
}

- (void)setFrame:(CGRect)frame inFullScreenMode:(BOOL)shouldBeFullScreenMode {
  self.view.frame = frame;
  
  CGFloat viewWidth = frame.size.width;
  CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  
  
  CGFloat offset = 23;
  CGFloat fieldSpacer = 7;
  
  // Title Region is the top 2/5ths of View. The Fields comprise the next 3/5ths.
  CGFloat gridSize = 44 / 2;
  
  CGFloat titleRegionHeight = gridSize * 2;
  CGFloat fieldRegionHeight = gridSize * 3;
  CGPoint titleRegionCenter = CGPointMake((viewWidth / 2), statusHeight + (titleRegionHeight / 2));
  CGPoint fieldRegionCenter =
      CGPointMake((viewWidth / 2), statusHeight + titleRegionHeight + (fieldRegionHeight / 2));
  
  
  CGRect navBarRect       = self.navBar.frame;
  CGRect peopleFieldRect  = self.peopleField.frame;
  CGRect messageFieldRect = self.messageField.frame;
  CGRect fieldDividerRect = self.fieldDivider.frame;

  /* Set Sizes */

  CGFloat fieldWidth = viewWidth - (2 * offset);
  

  navBarRect.size = CGSizeMake(viewWidth, statusHeight + titleRegionHeight);
  peopleFieldRect.size.width = fieldWidth;
  messageFieldRect.size.width = fieldWidth;
  
  if (shouldBeFullScreenMode) {
    fieldDividerRect.size = CGSizeMake(frame.size.width, 1 / [[UIScreen mainScreen] scale]);
  } else {
    fieldDividerRect.size = CGSizeMake(fieldWidth, 1 / [[UIScreen mainScreen] scale]);
  }
  

  /* Set Locations */

  if (shouldBeFullScreenMode) {
    navBarRect.origin = CGPointZero;
  } else {
    navBarRect.origin.y = frame.size.height - self.parentViewController.view.frame.size.height;
  }

  fieldDividerRect.origin = [self topLeftFromCenter:fieldRegionCenter size:fieldDividerRect.size];
  peopleFieldRect.origin =
      CGPointMake(offset,
                  fieldRegionCenter.y - peopleFieldRect.size.height - fieldSpacer);
  messageFieldRect.origin =
      CGPointMake(offset,
                  fieldRegionCenter.y + fieldSpacer);
  self.heading.center = titleRegionCenter;

  
  /* Commit Changes */
  
  self.fieldDivider.frame = fieldDividerRect;
  self.backgroundBar.frame = frame;
  self.navBar.frame = navBarRect;
  self.peopleField.frame  = peopleFieldRect;
  self.messageField.frame = messageFieldRect;
}

- (CGPoint)topLeftFromCenter:(CGPoint)center size:(CGSize)size {
  return CGPointMake(center.x - (size.width / 2), center.y - (size.height));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ButtonReciever methods

- (void)didTapOnCancel {
  
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  
  if (self.isFullScreen) {
    return YES;
  }
  
  self.navBar.alpha = 0.0;
  [self.view addSubview:self.navBar];

  [UIView animateWithDuration:0.4
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     
                     [self setFrame:self.parentViewController.view.frame inFullScreenMode:YES];
                     
                     
                     self.navBar.alpha = 1.0;
                     self.heading.alpha = 0.0;
                     
                     self.view.backgroundColor = [UIColor whiteColor];
                   }
                   completion:^(BOOL finished){
                     self.isFullScreen = finished;
                     [self.heading removeFromSuperview];
                     [textField becomeFirstResponder];
                   }];
  
  return self.isFullScreen;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.peopleField) {
    [self.messageField becomeFirstResponder];
  } else if (textField == self.messageField) {
    return [textField resignFirstResponder];
  }
  return YES;
}

#pragma mark Lazy Initializers

- (UILabel *)heading {
  if (!_heading) {
    _heading = [[UILabel alloc] initWithFrame:CGRectZero];
    _heading.text = WD_comp_title;
    _heading.textAlignment = NSTextAlignmentCenter;
    _heading.textColor = [UIColor whiteColor];
    _heading.font = [UIFont fontWithName:WD_comp_titleFont size:WD_comp_titleSize];
    [_heading sizeToFit];
  }
  return _heading;
}

- (UINavigationBar *)navBar {
  if (!_navBar) {
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    _navBar.translucent = YES;
    _navBar.shadowImage = [UIImage new];
    [_navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    UINavigationItem *newHangout = [[UINavigationItem alloc] initWithTitle:WD_comp_newEventTitle];
    _navBar.titleTextAttributes =
        @{NSFontAttributeName:            [UIFont fontWithName:WD_comp_newEventTitleFont
                                                          size:WD_comp_newEventTitleSize],
          NSForegroundColorAttributeName: [UIColor whiteColor]};
    newHangout.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(didTapOnCancel)];
    
    _navBar.items = @[newHangout];
    _navBar.tintColor = [UIColor whiteColor];

  }
  return _navBar;
}

- (UIToolbar *)backgroundBar {
  if (!_backgroundBar) {
    _backgroundBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    _backgroundBar.barTintColor = WD_UIColor_green;
    _backgroundBar.tintColor = [UIColor whiteColor];
    _backgroundBar.translucent = YES;
  }
  return _backgroundBar;
}

- (UITextField *)peopleField {
  if (!_peopleField) {
    _peopleField = [[UITextField alloc] initWithFrame:CGRectZero];
    _peopleField.textAlignment = NSTextAlignmentLeft;
    _peopleField.textColor = [UIColor whiteColor];
    _peopleField.font = [UIFont fontWithName:WD_comp_fieldFont size:WD_comp_fieldSize];
    _peopleField.placeholder = WD_comp_peopleFieldPlaceholder;
    _peopleField.returnKeyType = UIReturnKeyNext;
    [_peopleField sizeToFit];
    
    _peopleField.delegate = self;
  }
  return _peopleField;
}

- (UITextField *)messageField {
  if (!_messageField) {
    _messageField = [[UITextField alloc] initWithFrame:CGRectZero];
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
    _fieldDivider = [[UIView alloc] initWithFrame:CGRectZero];
    _fieldDivider.backgroundColor = [UIColor grayColor];
  }
  return _fieldDivider;
}

@end
