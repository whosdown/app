//
//  WDVerifyVC.m
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDVerifyVC.h"

#import "WDConstants.h"
#import "WDVerifyDelegate.h"

@interface WDVerifyVC ()
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *undoButton;
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UILabel *pending;
@property (nonatomic, strong) UILabel *subHeading;
@property (nonatomic, strong) UILabel *undoButtonLabel;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UIView *fieldDivider;


@property BOOL keyboardIsVisible;

@property CGFloat gridSize;

@property NSObject<WDVerifyDelegate> *delegate;
@end

@implementation WDVerifyVC

- (id)initWithDelegate:(NSObject<WDVerifyDelegate> *)delegate {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _delegate = delegate;
    _keyboardIsVisible = NO;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  self.gridSize = self.view.bounds.size.height / 5;

  self.view.backgroundColor = WD_UIColor_green;
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  
  CGFloat gridSpacer = 7;
  CGFloat offset = 30;

  [self setUpHeadingWithGridSize:self.gridSize withSpacer:gridSpacer];
  [self setUpFieldsWithGridSize:self.gridSize withSpacer:gridSpacer withEdgeOffset:offset];
  [self setUpPendingViewsWithEdgeOffset:offset * 2];
  
  [self.view addSubview:self.heading];
  [self.view addSubview:self.subHeading];
  [self.view addSubview:self.nameField];
  [self.view addSubview:self.phoneField];
  [self.view addSubview:self.fieldDivider];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)setUpHeadingWithGridSize:(CGFloat)gridSize withSpacer:(CGFloat)gridSpacer {
  CGFloat viewWidth = self.view.bounds.size.width;
  
  CGRect headingRect = CGRectMake((viewWidth / 2) - (self.heading.frame.size.width / 2),
                                  gridSize,
                                  self.heading.frame.size.width,
                                  self.heading.frame.size.height);
  self.heading.alpha = 1.0;
  self.heading.transform = CGAffineTransformIdentity;
  self.heading.frame = headingRect;
  
  CGRect subHeadingRect = CGRectMake((viewWidth / 2) - (self.subHeading.frame.size.width / 2),
                                     headingRect.origin.y + headingRect.size.height + gridSpacer,
                                     self.subHeading.frame.size.width,
                                     self.subHeading.frame.size.height);
  self.subHeading.alpha = 1.0;
  self.subHeading.transform = CGAffineTransformIdentity;
  self.subHeading.frame = subHeadingRect;
}

- (void)setUpFieldsWithGridSize:(CGFloat)gridSize
                     withSpacer:(CGFloat)gridSpacer
                 withEdgeOffset:(CGFloat)offset {
  CGFloat viewWidth = self.view.bounds.size.width;
  
  CGRect phoneFieldRect = CGRectMake(offset,
                                     (gridSize * 2) + (gridSize / 2),
                                     viewWidth - (2 * offset),
                                     self.phoneField.frame.size.height);
  self.phoneField.alpha = 1.0;
  self.phoneField.transform = CGAffineTransformIdentity;
  self.phoneField.frame = phoneFieldRect;
  
  CGRect nameFieldRect = CGRectMake(phoneFieldRect.origin.x,
                                    phoneFieldRect.origin.y + phoneFieldRect.size.height + (gridSpacer * 2),
                                    phoneFieldRect.size.width,
                                    phoneFieldRect.size.height);
  self.nameField.alpha = 1.0;
  self.nameField.transform = CGAffineTransformIdentity;
  self.nameField.frame = nameFieldRect;
  
  
  CGFloat fieldDividerY = CGRectGetMinY(phoneFieldRect) + ((CGRectGetMaxY(nameFieldRect) - CGRectGetMinY(phoneFieldRect)) / 2);
  CGRect fieldDividerRect = CGRectMake(phoneFieldRect.origin.x,
                                       fieldDividerY,
                                       phoneFieldRect.size.width,
                                       1 / [[UIScreen mainScreen] scale]);
  self.fieldDivider.alpha = 1.0;
  self.fieldDivider.transform = CGAffineTransformIdentity;
  self.fieldDivider.frame = fieldDividerRect;
}

- (void)setUpPendingViewsWithEdgeOffset:(CGFloat)offset {
  CGFloat viewWidth = self.view.bounds.size.width;
  CGFloat viewHeight = self.view.bounds.size.height;

  CGRect pendingRect = CGRectMake(offset,
                                  (viewHeight / 2) - self.gridSize,
                                  viewWidth - (2 * offset),
                                  self.gridSize * 2);
  self.pending.frame = pendingRect;
  self.pending.center = CGPointMake(viewWidth / 2, self.fieldDivider.frame.origin.y);
  
  CGRect undoRect = CGRectMake(offset,
                               viewHeight - self.gridSize,
                               viewWidth - (2 * offset),
                               self.gridSize);
  self.undoButton.frame = undoRect;

  CGRect undoButtonLabelRect = CGRectMake((undoRect.size.width / 2) - (self.undoButtonLabel.frame.size.width / 2),
                                          0,
                                          self.undoButtonLabel.frame.size.width,
                                          undoRect.size.height);
  self.undoButtonLabel.frame = undoButtonLabelRect;
  [self.undoButton addTarget:self
                      action:@selector(didTapOnUndoButton)
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)verifyDidInitiate {
  self.pending.alpha = 0.0;
  self.pending.transform = CGAffineTransformMakeScale(2.0, 2.0);
  self.undoButton.alpha = 0.0;
  self.undoButton.transform = CGAffineTransformMakeScale(2.0, 2.0);
  [self.view addSubview:self.pending];
  [self.view addSubview:self.undoButton];

  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.pending.alpha = 1.0;
                     self.pending.transform = CGAffineTransformIdentity;
                     self.undoButton.alpha = 1.0;
                     self.undoButton.transform = CGAffineTransformIdentity;
                     
                     self.nameField.alpha = 0.0;
                     self.nameField.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     self.phoneField.alpha = 0.0;
                     self.phoneField.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     self.fieldDivider.alpha = 0.0;
                     self.fieldDivider.transform = CGAffineTransformMakeScale(0.1, 0.1);
                   }
                   completion:^(BOOL finished){
                     [self.nameField removeFromSuperview];
                     [self.phoneField removeFromSuperview];
                     [self.fieldDivider removeFromSuperview];
                   }];
}

- (void)verifyDidSucceed {
  
}

- (void)verifyDidFail {
  
}

- (void)didTapOnUndoButton {
  // TODO: Invalidate old request.
  
  self.nameField.alpha = 0.0;
  self.nameField.transform = CGAffineTransformMakeScale(0.1, 0.1);
  self.phoneField.alpha = 0.0;
  self.phoneField.transform = CGAffineTransformMakeScale(0.1, 0.1);
  self.fieldDivider.alpha = 0.0;
  self.fieldDivider.transform = CGAffineTransformMakeScale(0.1, 0.1);
  [self.view addSubview:self.nameField];
  [self.view addSubview:self.phoneField];
  [self.view addSubview:self.fieldDivider];
  
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.pending.alpha = 0.0;
                     self.pending.transform = CGAffineTransformMakeScale(2.0, 2.0);
                     self.undoButton.alpha = 0.0;
                     self.undoButton.transform = CGAffineTransformMakeScale(2.0, 2.0);
                     
                     self.nameField.alpha = 1.0;
                     self.nameField.transform = CGAffineTransformIdentity;
                     self.phoneField.alpha = 1.0;
                     self.phoneField.transform = CGAffineTransformIdentity;
                     self.fieldDivider.alpha = 1.0;
                     self.fieldDivider.transform = CGAffineTransformIdentity;
                   }
                   completion:^(BOOL finished){
                     [self.pending removeFromSuperview];
                     [self.undoButton removeFromSuperview];
                   }];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  
  if (textField == self.nameField && [self getLength:self.phoneField.text] == 10) {
    [self.delegate verifyUserWithName:self.nameField.text
                          phoneNumber:[self formatNumber:self.phoneField.text]];

//    NSNumber *random = [NSNumber numberWithInt:abs(arc4random() % 10000000000)];
//    NSLog(@"Random # = %@",random);
//    [self.delegate verifyUserWithName:@"Bob" phoneNumber:random];

    [textField resignFirstResponder];
  } else {
    [textField resignFirstResponder];
  }

  return NO;
}

-(NSInteger)getLength:(NSString*)mobileNumber {
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
  
  int length = [mobileNumber length];
  
  return length;
}

-(NSString *)formatNumber:(NSString *)mobileNumber {
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
  int length = [mobileNumber length];
  if(length > 10)
  {
    mobileNumber = [mobileNumber substringFromIndex:length - 10];
  }
  return mobileNumber;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  NSInteger length = [self getLength:textField.text];
  
  if (textField == self.nameField) {
    return YES;
  }
  
  
  if(length == 10) {
    if(range.length == 0) {
      return NO;
    }
  }
  
  if(length == 3) {
    NSString *num = [self formatNumber:textField.text];
    textField.text = [NSString stringWithFormat:@"(%@) ",num];
    if(range.length > 0)
      textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
  } else if(length == 6) {
    NSString *num = [self formatNumber:textField.text];
    textField.text = [NSString stringWithFormat:@"(%@) %@-",[num substringToIndex:3],[num substringFromIndex:3]];
    if(range.length > 0) {
      textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
  }
  
  return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;

  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  
  CGRect headingRect = self.heading.frame;
  headingRect.origin.y = headingRect.origin.y - (self.gridSize / 3);
  self.heading.frame = headingRect;
  
  CGRect subHeadingRect = self.subHeading.frame;
  subHeadingRect.origin.y = subHeadingRect.origin.y - (self.gridSize / 3);
  self.subHeading.frame = subHeadingRect;
  
  
  CGRect nameFieldRect = self.nameField.frame;
  nameFieldRect.origin.y = nameFieldRect.origin.y - (self.gridSize / 2);
  self.nameField.frame = nameFieldRect;
  
  CGRect dividerRect = self.fieldDivider.frame;
  dividerRect.origin.y = dividerRect.origin.y - (self.gridSize / 2);
  self.fieldDivider.frame = dividerRect;
  
  CGRect phoneFieldRect = self.phoneField.frame;
  phoneFieldRect.origin.y = phoneFieldRect.origin.y - (self.gridSize / 2);
  self.phoneField.frame = phoneFieldRect;
  
  [UIView commitAnimations];
}
                                                 
- (void)keyboardWillHide:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  
  CGRect headingRect = self.heading.frame;
  headingRect.origin.y = headingRect.origin.y + (self.gridSize / 3);
  self.heading.frame = headingRect;
  
  CGRect subHeadingRect = self.subHeading.frame;
  subHeadingRect.origin.y = subHeadingRect.origin.y + (self.gridSize / 3);
  self.subHeading.frame = subHeadingRect;
  
  
  CGRect nameFieldRect = self.nameField.frame;
  nameFieldRect.origin.y = nameFieldRect.origin.y + (self.gridSize / 2);
  self.nameField.frame = nameFieldRect;
  
  CGRect dividerRect = self.fieldDivider.frame;
  dividerRect.origin.y = dividerRect.origin.y + (self.gridSize / 2);
  self.fieldDivider.frame = dividerRect;
  
  CGRect phoneFieldRect = self.phoneField.frame;
  phoneFieldRect.origin.y = phoneFieldRect.origin.y + (self.gridSize / 2);
  self.phoneField.frame = phoneFieldRect;
  
  [UIView commitAnimations];
}

#pragma mark Lazy Initializers

- (UILabel *)heading {
  if (!_heading) {
    _heading = [[UILabel alloc] init];
    _heading.text = WD_veri_title;
    _heading.textAlignment = NSTextAlignmentCenter;
    _heading.textColor = [UIColor whiteColor];
    _heading.font = [UIFont fontWithName:WD_FONT_brand size:WD_veri_titleSize];
    [_heading sizeToFit];
  }
  return _heading;
}

- (UILabel *)subHeading {
  if (!_subHeading) {
    _subHeading = [[UILabel alloc] init];
    _subHeading.text = WD_veri_tagLine;
    _subHeading.textAlignment = NSTextAlignmentCenter;
    _subHeading.textColor = [UIColor whiteColor];
    _subHeading.font = [UIFont fontWithName:WD_veri_tagLineFont size:WD_veri_tagLineSize];
    [_subHeading sizeToFit];
  }
  return _subHeading;
}

- (UITextField *)phoneField {
  if (!_phoneField) {
    _phoneField = [[UITextField alloc] init];
    _phoneField.textAlignment = NSTextAlignmentLeft;
    _phoneField.textColor = [UIColor blackColor];
    _phoneField.font = [UIFont fontWithName:WD_veri_fieldFont  size:WD_veri_fieldSize];
    _phoneField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneField.placeholder = WD_veri_phoneFieldPlaceholder;
    _phoneField.returnKeyType = UIReturnKeyDone;
    [_phoneField sizeToFit];

    _phoneField.delegate = self;
  }
  return _phoneField;
}

- (UITextField *)nameField {
  if (!_nameField) {
    _nameField = [[UITextField alloc] init];
    _nameField.textAlignment = self.phoneField.textAlignment;
    _nameField.textColor = self.phoneField.textColor;
    _nameField.font = self.phoneField.font;
    _nameField.placeholder = WD_veri_nameFieldPlaceholder;
    _nameField.returnKeyType = UIReturnKeyDone;
    _nameField.enablesReturnKeyAutomatically = YES;
    [_nameField sizeToFit];
    
    _nameField.delegate = self;
  }
  return _nameField;
}

- (UIView *)fieldDivider {
  if (!_fieldDivider) {
    _fieldDivider = [[UIView alloc] init];
    _fieldDivider.backgroundColor = [UIColor grayColor];
  }
  return _fieldDivider;
}

- (UILabel *)pending {
  if (!_pending) {
    _pending = [[UILabel alloc] init];
    _pending.text = WD_veri_pending;
    _pending.textAlignment = NSTextAlignmentCenter;
    _pending.textColor = [UIColor whiteColor];
    _pending.font = [UIFont fontWithName:WD_veri_pendingFont size:WD_veri_pendingSize];
    _pending.numberOfLines = 3;
    [_pending sizeToFit];
  }
  return _pending;
}

- (UIButton *)undoButton {
  if (!_undoButton) {
    _undoButton = [[UIButton alloc] init];

    [_undoButton addSubview:self.undoButtonLabel];
  }
  return _undoButton;
}

- (UILabel *)undoButtonLabel {
  if (!_undoButtonLabel) {
    _undoButtonLabel = [[UILabel alloc] init];
    _undoButtonLabel.text = WD_veri_undo;
    _undoButtonLabel.textAlignment = NSTextAlignmentCenter;
    _undoButtonLabel.textColor = [UIColor grayColor];
    _undoButtonLabel.font = [UIFont fontWithName:WD_veri_undoFont size:WD_veri_undoSize];
    [_undoButtonLabel sizeToFit];
  }
  return _undoButtonLabel;
}

@end
