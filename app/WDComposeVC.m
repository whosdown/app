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
#import "WDPeopleModel.h"

#import <AddressBookUI/AddressBookUI.h>


@interface WDComposeVC ()

@property BOOL isFullScreen;

@property NSObject<WDComposeDataSource> *dataSource;
@property NSObject<WDComposeDelegate> *delegate;
@property CGRect contentFrame;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UILabel *charCount;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UITextField *peopleField;
@property (nonatomic, strong) UITextView *messageField;
@property (nonatomic, strong) UIToolbar *backgroundBar;
@property (nonatomic, strong) UIView *fieldDivider;

@property (nonatomic, strong) WDPeopleModel *peopleModel;
@property (nonatomic, strong) ABPeoplePickerNavigationController *peopleVC;

@property (nonatomic, strong) NSMutableArray *invitees;
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
    _peopleModel = [[WDPeopleModel alloc] init];
    _invitees = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.isFullScreen = false;
  [self.peopleModel setUp];
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
  CGRect charCountRect    = self.peopleField.frame;

  /* Set Sizes */

  CGFloat fieldWidth = viewWidth - (2 * offset);
  

  navBarRect.size = CGSizeMake(viewWidth, statusHeight + titleRegionHeight);
  peopleFieldRect.size.width = fieldWidth;
  messageFieldRect.size.width = fieldWidth;
  charCountRect.size = peopleFieldRect.size;
  
  if (shouldBeFullScreenMode) {
    fieldDividerRect.size = CGSizeMake(frame.size.width, 1 / [[UIScreen mainScreen] scale]);
    messageFieldRect.size.height = peopleFieldRect.size.height * 4;
  } else {
    fieldDividerRect.size = CGSizeMake(fieldWidth, 1 / [[UIScreen mainScreen] scale]);
  }
  

  /* Set Locations */

  if (shouldBeFullScreenMode) {
    navBarRect.origin = CGPointZero;
  } else {
    navBarRect.origin.y = frame.size.height - self.parentViewController.view.frame.size.height;
  }

  fieldDividerRect.origin  = [self topLeftFromCenter:fieldRegionCenter size:fieldDividerRect.size];
  peopleFieldRect.origin.x = offset;
  peopleFieldRect.origin.y = fieldRegionCenter.y - peopleFieldRect.size.height - fieldSpacer;
  messageFieldRect.origin.x = offset;
  messageFieldRect.origin.y = fieldRegionCenter.y + fieldSpacer;
  charCountRect.origin.x = offset;
  charCountRect.origin.y = fieldRegionCenter.y + messageFieldRect.size.height + gridSize;
  self.heading.center = titleRegionCenter;
  self.submitButton.center = CGPointMake(fieldRegionCenter.x,
                                         fieldRegionCenter.y + fieldRegionHeight * 2);
  
  /* Commit Changes */
  
  self.fieldDivider.frame  = fieldDividerRect;
  self.backgroundBar.frame = frame;
  self.navBar.frame        = navBarRect;
  self.peopleField.frame   = peopleFieldRect;
  self.messageField.frame  = messageFieldRect;
  self.charCount.frame     = charCountRect;
}

- (void)transitionToFullScreenWithView:(UIView *)view {
  self.navBar.alpha = 0.0;
  self.charCount.alpha = 0.0;
  self.submitButton.alpha = 0.0;
  [self.view addSubview:self.navBar];
  [self.view addSubview:self.charCount];
  [self.view addSubview:self.submitButton];
  
  [UIView animateWithDuration:0.4
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     
                     [self setFrame:self.parentViewController.view.frame inFullScreenMode:YES];
                     
                     self.navBar.alpha = 1.0;
                     self.charCount.alpha = 1.0;
                     self.submitButton.alpha = 1.0;
                     self.heading.alpha = 0.0;
                     
                     self.view.backgroundColor = [UIColor whiteColor];
                   }
                   completion:^(BOOL finished){
                     self.isFullScreen = finished;
                     [self.heading removeFromSuperview];
                     
                     if (view) {
                       [view becomeFirstResponder];
                     }
                   }];
}

- (void)transitionOutOfFullScreen {
  BOOL peopleVCIsPresented = self.peopleField.isFirstResponder;

  [self.invitees removeAllObjects];
  [self listInvitees];
  self.messageField.text = @"";
  [self textViewDidChange:self.messageField];
  [self textViewDidEndEditing:self.messageField];
  
  [self.peopleField resignFirstResponder];
  [self.messageField resignFirstResponder];
  
  [UIView animateWithDuration:0.4
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self setFrame:self.contentFrame inFullScreenMode:NO];
                     self.navBar.alpha = 0.0;
                     self.charCount.alpha = 0.0;
                     self.submitButton.alpha = 0.0;
                     self.heading.alpha = 1.0;
                     if (peopleVCIsPresented) {
                       [self hidePeopleVCWithAnimation:NO];
                     }
                   }
                   completion:^(BOOL finished){
                     self.isFullScreen = !finished;
                     [self.navBar removeFromSuperview];
                     [self.charCount removeFromSuperview];
                     [self.submitButton removeFromSuperview];
                   }];
}

- (void)presentPeopleVC {
  [self presentViewController:self.peopleVC animated:YES completion:nil];
  
//  [self addChildViewController:self.peopleVC];
//  self.peopleVC.view.frame = self.fieldDivider.frame;
//  [self.view addSubview:self.peopleVC.view];
//  [self.peopleVC didMoveToParentViewController:self];
//  
//  CGRect peopleVCFrame = self.peopleVC.view.frame;
//  peopleVCFrame.size.height = self.view.frame.size.height - peopleVCFrame.origin.y - 216;
  
//  [UIView animateWithDuration:0.4
//                        delay:0.0
//                      options:UIViewAnimationOptionCurveEaseOut
//                   animations:^{
//                     self.peopleVC.view.frame = peopleVCFrame;
//                   } completion:^(BOOL finished){
//                   }];
}

- (void)hidePeopleVCWithAnimation:(BOOL)shouldBeAnimated {
  [self dismissViewControllerAnimated:YES completion:nil];
//  void (^viewTransition)(void) = ^{
//    self.peopleVC.view.frame = self.fieldDivider.frame;
//  };
//  
//  void (^viewControllerTransition)(BOOL) = ^(BOOL finished){
//    [self.peopleVC willMoveToParentViewController:nil];
//    [self.peopleVC.view removeFromSuperview];
//    [self.peopleVC removeFromParentViewController];
//  };
//  
//  if (shouldBeAnimated) {
//    [UIView animateWithDuration:0.4
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:viewTransition
//                     completion:viewControllerTransition];
//  } else {
//    viewTransition();
//    viewControllerTransition(YES);
//  }

}

- (void)listInvitees {
  NSMutableArray *inviteeNames = [[NSMutableArray alloc] initWithCapacity:[self.invitees count]];
  for (id person in self.invitees) {
    ABRecordRef personRecord = (__bridge ABRecordRef)person;
    NSString *personName = [self.peopleModel fullNameForPerson:personRecord];
    [inviteeNames addObject:personName];
  }
  self.peopleField.text = [inviteeNames componentsJoinedByString:@", "];
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
  if (!self.isFullScreen) {
    return;
  }
  
  self.heading.alpha = 0.0;
  [self.view addSubview:self.heading];
  
  [self transitionOutOfFullScreen];
}

- (void)didTapOnSubmit {
  NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:[self.invitees count]];
  
  for (id person in self.invitees) {
    ABRecordRef personRecord = (__bridge ABRecordRef)person;
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(personRecord);
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(personRecord, kABPersonPhoneProperty);
    NSInteger phoneNumbersCount = ABMultiValueGetCount(phoneNumbers);
    NSString *phone;
    
    if (phoneNumbersCount > 0) {
      phone = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    
    [recipients addObject:@{ WD_modelKey_User_name  : name,
                             WD_modelKey_User_phone : [self.peopleModel sanitizePhoneNumber:phone] }];
  }
  
  [self.delegate createEventWithPeople:recipients message:self.messageField.text];
  [self transitionOutOfFullScreen];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (!self.isFullScreen) {
    [self transitionToFullScreenWithView:textField];
  } else {
//    if (textField == self.peopleField) {
//      [self presentPeopleVC];
//    }
  }
  
  return self.isFullScreen;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.peopleField) {
    [self hidePeopleVCWithAnimation:YES];
    [self.messageField becomeFirstResponder];
  }
  return YES;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (textField == self.peopleField) {
    if ([string isEqualToString:@""]) {
      [self.invitees removeLastObject];
      [self listInvitees];
      return NO;
    }
    [self presentPeopleVC];
  }
  return YES;
}

#pragma mark UITextViewDelegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
  if (!self.isFullScreen) {
    [self transitionToFullScreenWithView:textView];
  }
  
  if ([textView.text isEqualToString:WD_comp_messageFieldPlaceholder]) {
    textView.text = @"";
    textView.textColor = [UIColor whiteColor]; //optional
    textView.alpha = 1.0;
  }
  [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  if ([textView.text isEqualToString:@""]) {
    textView.text = WD_comp_messageFieldPlaceholder;
    textView.textColor = [UIColor grayColor]; //optional
    textView.alpha = 0.6;
  }
  [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
  NSInteger length = textView.text.length;
  self.charCount.text = [NSString stringWithFormat:@"%d / 160", length];
}

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  
  
  return YES;
}
#pragma mark Picker delegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
  [self.invitees addObject:(__bridge id)(person)];
  [self listInvitees];
  [self hidePeopleVCWithAnimation:YES];
  [self.peopleField becomeFirstResponder];
  return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
  return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
  [self hidePeopleVCWithAnimation:YES];
}

#pragma mark Lazy Initializers

- (UIButton *)submitButton {
  if (!_submitButton) {
    _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    [_submitButton addTarget:self
                      action:@selector(didTapOnSubmit)
            forControlEvents:UIControlEventTouchUpInside];
    _submitButton.backgroundColor = [UIColor blackColor];
    _submitButton.layer.cornerRadius = _submitButton.bounds.size.width / 2;

    [_submitButton setTitle:WD_comp_submitButtonTitle forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_submitButton setShowsTouchWhenHighlighted:YES];
  }
  return _submitButton;
}

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

- (UILabel *)charCount {
  if (!_charCount) {
    _charCount = [[UILabel alloc] initWithFrame:CGRectZero];
    _charCount.text = @"0 / 160";
    _charCount.textAlignment = NSTextAlignmentRight;
    _charCount.textColor = [UIColor whiteColor];
    _charCount.font = [UIFont fontWithName:WD_comp_fieldFont size:WD_comp_fieldSize];
    [_charCount sizeToFit];
  }
  return _charCount;
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

- (UITextView *)messageField {
  if (!_messageField) {
    _messageField = [[UITextView alloc] initWithFrame:CGRectZero];
    _messageField.textContainerInset = UIEdgeInsetsMake(0, -6, 0, 0);
    _messageField.textContainer.widthTracksTextView = YES;
    _messageField.textAlignment = NSTextAlignmentLeft;
    _messageField.text = WD_comp_messageFieldPlaceholder;
    _messageField.alpha = 0.6;
    _messageField.textColor = [UIColor grayColor];
    _messageField.font = [UIFont fontWithName:WD_comp_fieldFont size:WD_comp_fieldSize];
//    _messageField.returnKeyType = UIReturnKeyDone;
    _messageField.backgroundColor = [UIColor clearColor];

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

- (ABPeoplePickerNavigationController *)peopleVC {
  if (!_peopleVC) {
    _peopleVC = [[ABPeoplePickerNavigationController alloc] init];
    _peopleVC.peoplePickerDelegate = self;
  }
  return _peopleVC;
}

@end
