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
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UILabel *subHeading;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *phoneField;

@property (nonatomic, strong) UIView *fieldDivider;

@property (nonatomic, strong) UIButton *submitButton;

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

  self.view.backgroundColor = UIColorFromHex(WD_GREEN_COLOR);
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  
  CGFloat gridSpacer = 7;
  CGFloat offset = 30;

  [self setUpHeadingWithGridSize:self.gridSize withSpacer:gridSpacer];
  [self setUpFieldsWithGridSize:self.gridSize withSpacer:gridSpacer withEdgeOffset:offset];
  
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
  
  self.heading = [[UILabel alloc] init];
  self.heading.text = WD_TITLE;
  self.heading.textAlignment = NSTextAlignmentCenter;
  self.heading.textColor = [UIColor whiteColor];
  self.heading.font = [UIFont fontWithName:WD_TITLE_FONT size:45];
  [self.heading sizeToFit];
  CGRect headingRect = CGRectMake((viewWidth / 2) - (self.heading.frame.size.width / 2),
                                  gridSize,
                                  self.heading.frame.size.width,
                                  self.heading.frame.size.height);
  self.heading.frame = headingRect;
  
  
  self.subHeading = [[UILabel alloc] init];
  self.subHeading.text = WD_TAG_LINE;
  self.subHeading.textAlignment = NSTextAlignmentCenter;
  self.subHeading.textColor = [UIColor whiteColor];
  self.subHeading.font = [UIFont fontWithName:WD_TAG_LINE_FONT size:20];
  [self.subHeading sizeToFit];
  CGRect subHeadingRect = CGRectMake((viewWidth / 2) - (self.subHeading.frame.size.width / 2),
                                     headingRect.origin.y + headingRect.size.height + gridSpacer,
                                     self.subHeading.frame.size.width,
                                     self.subHeading.frame.size.height);
  self.subHeading.frame = subHeadingRect;
}

- (void)setUpFieldsWithGridSize:(CGFloat)gridSize
                     withSpacer:(CGFloat)gridSpacer
                 withEdgeOffset:(CGFloat)offset {
  CGFloat viewWidth = self.view.bounds.size.width;
  
  self.phoneField = [[UITextField alloc] init];
  self.phoneField.textAlignment = NSTextAlignmentLeft;
  self.phoneField.textColor = [UIColor blackColor];
  self.phoneField.font = [UIFont fontWithName:WD_TITLE_FONT size:20];
  self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
  self.phoneField.placeholder = @"Phone number";
  self.phoneField.returnKeyType = UIReturnKeyDone;
  [self.phoneField sizeToFit];
  CGRect phoneFieldRect = CGRectMake(offset,
                                     (gridSize * 2) + (gridSize / 2),
                                     viewWidth - (2 * offset),
                                     self.phoneField.frame.size.height);
  self.phoneField.frame = phoneFieldRect;
  
  self.nameField = [[UITextField alloc] init];
  self.nameField.textAlignment = self.phoneField.textAlignment;
  self.nameField.textColor = self.phoneField.textColor;
  self.nameField.font = self.phoneField.font;
  self.nameField.placeholder = @"Name";
  self.nameField.returnKeyType = UIReturnKeyDone;
  self.nameField.enablesReturnKeyAutomatically = YES;
  [self.nameField sizeToFit];
  CGRect nameFieldRect = CGRectMake(phoneFieldRect.origin.x,
                                    phoneFieldRect.origin.y + phoneFieldRect.size.height + (gridSpacer * 2),
                                    phoneFieldRect.size.width,
                                    phoneFieldRect.size.height);

  self.nameField.frame = nameFieldRect;
  
  
  CGFloat fieldDividerY = CGRectGetMinY(phoneFieldRect) + ((CGRectGetMaxY(nameFieldRect) - CGRectGetMinY(phoneFieldRect)) / 2);
  CGRect fieldDividerRect = CGRectMake(phoneFieldRect.origin.x,
                                       fieldDividerY,
                                       phoneFieldRect.size.width,
                                       1 / [[UIScreen mainScreen] scale]);
  self.fieldDivider = [[UIView alloc] initWithFrame:fieldDividerRect];
  self.fieldDivider.backgroundColor = [UIColor grayColor];
  
  self.nameField.delegate = self;
  self.phoneField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)verifyDidInitiate {
  
}

- (void)verifyDidSucceed {
  
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  
//  if (textField == self.nameField && [self getLength:self.phoneField.text] == 10) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *num = [formatter numberFromString:[self formatNumber:self.phoneField.text]];
    
//    [self.delegate verifyUserWithName:self.nameField.text phoneNumber:num];  
    [self.delegate verifyUserWithName:@"Bob" phoneNumber:[NSNumber numberWithInt:arc4random() % 1000000]];

    [textField resignFirstResponder];
//  }
  
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
  
//  NSInteger newTextLength = length - range.length + string.length;
//  if (newTextLength == 10) {
//    self.verifyBarButton.enabled = YES;
//    self.verifyButton.enabled = YES;
//  } else {
//    self.verifyBarButton.enabled = NO;
//    self.verifyButton.enabled = NO;
//  }
//  
//  if (newTextLength > 0 && self.displayingLoginButton) {
//    [self.loginButton removeFromSuperview];
//    self.displayingLoginButton = NO;
//    [self addAndSlideUpButton:self.verifyButton];
//  } else if (newTextLength == 0 && !self.displayingLoginButton) {
//    [self.verifyButton removeFromSuperview];
//    self.displayingLoginButton = YES;
//    [self.view addSubview:self.loginButton];
//  }
  
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
                                                 

@end
