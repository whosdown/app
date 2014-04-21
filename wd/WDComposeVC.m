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
@property CGRect halfScreenFrame;

@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *contactsChooserButton;
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UILabel *charCount;
@property (nonatomic, strong) UILabel *pending;
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

- (id)initWithDelegate:(NSObject<WDComposeDelegate> *)delegate
            dataSource:(NSObject<WDComposeDataSource> *)dataSource {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _dataSource = dataSource;
    _delegate = delegate;
    _peopleModel = [[WDPeopleModel alloc] init];
    _invitees = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.isFullScreen = false;
  [self.peopleModel setUp];
  [self setFrame:self.halfScreenFrame inFullScreenMode:NO];

  [self.view addSubview:self.backgroundBar];
  [self.view addSubview:self.heading];
  [self.view addSubview:self.peopleField];
  [self.view addSubview:self.messageField];
  [self.view addSubview:self.fieldDivider];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
  self.halfScreenFrame = self.view.frame;
}

- (CGPoint)topLeftFromCenter:(CGPoint)center size:(CGSize)size {
  return CGPointMake(center.x - (size.width / 2), center.y - (size.height));
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
  CGRect charCountRect    = self.charCount.frame;

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

  fieldDividerRect.origin  = [self topLeftFromCenter:fieldRegionCenter size:fieldDividerRect.size];
  peopleFieldRect.origin.x = offset;
  peopleFieldRect.origin.y = fieldRegionCenter.y - peopleFieldRect.size.height - fieldSpacer;
  messageFieldRect.origin.x = offset;
  messageFieldRect.origin.y = fieldRegionCenter.y + fieldSpacer;
  charCountRect.origin.x = offset;
  charCountRect.origin.y = fieldRegionCenter.y + messageFieldRect.size.height + gridSize;
  
  if (shouldBeFullScreenMode) {
    navBarRect.origin = CGPointZero;
  } else {
    navBarRect.origin.y = frame.size.height - self.parentViewController.view.frame.size.height;
//    charCountRect.origin.y = fieldRegionCenter.y + messageFieldRect.size.height;
  }

  self.heading.center = CGPointMake(titleRegionCenter.x, titleRegionCenter.y + 5);
  self.submitButton.center = CGPointMake(fieldRegionCenter.x,
                                         fieldRegionCenter.y + fieldRegionHeight * 2);
  self.pending.center = self.submitButton.center;
  self.contactsChooserButton.center =
  CGPointMake(peopleFieldRect.origin.x + peopleFieldRect.size.width - (self.contactsChooserButton.frame.size.width / 2),
              peopleFieldRect.origin.y + (peopleFieldRect.size.height / 2));

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
  self.contactsChooserButton.alpha = 0.0;
  [self.view addSubview:self.navBar];
  [self.view addSubview:self.charCount];
  [self.view addSubview:self.submitButton];
  [self.view addSubview:self.contactsChooserButton];

  
  [UIView animateWithDuration:0.4
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self setFrame:self.parentViewController.view.frame inFullScreenMode:YES];
                     
                     self.navBar.alpha = 1.0;
                     self.charCount.alpha = 1.0;
                     self.submitButton.alpha = 1.0;
                     self.contactsChooserButton.alpha = 1.0;
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
  
  self.heading.alpha = 0.0;
  [self.view addSubview:self.heading];
  
  [UIView animateWithDuration:0.4
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self setFrame:self.halfScreenFrame inFullScreenMode:NO];

                     self.peopleField.alpha  = 1.0;
                     self.messageField.alpha = 0.6;
                     
                     self.navBar.alpha       = 0.0;
                     self.charCount.alpha    = 0.0;
                     self.submitButton.alpha = 0.0;
                     self.contactsChooserButton.alpha = 0.0;
                     self.pending.alpha      = 0.0;
                     self.heading.alpha      = 1.0;
                     if (peopleVCIsPresented) {
                       [self hidePeopleVCWithAnimation:NO];
                     }
                     
                     self.view.backgroundColor = [UIColor clearColor];
                   }
                   completion:^(BOOL finished){
                     self.isFullScreen = !finished;
                     self.charCount.transform    = CGAffineTransformIdentity;
                     self.submitButton.transform = CGAffineTransformIdentity;
                     
                     [self.navBar removeFromSuperview];
                     [self.pending removeFromSuperview];
                     [self.charCount removeFromSuperview];
                     [self.submitButton removeFromSuperview];
                     [self.contactsChooserButton removeFromSuperview];
                   }];
}

- (void)transitionToPendingMode {
  self.pending.alpha = 0.0;
  self.pending.transform = CGAffineTransformMakeScale(2.0, 2.0);
  [self.view addSubview:self.pending];

  [self.peopleField resignFirstResponder];
  [self.messageField resignFirstResponder];
  
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.pending.alpha      = 1.0;
                     self.charCount.alpha    = 0.0;
                     self.submitButton.alpha = 0.0;
                     self.peopleField.alpha  = 0.5;
                     self.messageField.alpha = 0.1;

                     self.pending.transform      = CGAffineTransformIdentity;
                     self.charCount.transform    = CGAffineTransformMakeScale(0.1, 0.1);
                     self.submitButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
                   }
                   completion:^(BOOL finished){
                     [self.charCount removeFromSuperview];
                     [self.submitButton removeFromSuperview];
                   }];
}

- (void)presentPeopleVC {
  [self transitionToFullScreenWithView:nil];
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
  for (NSDictionary *person in self.invitees) {
    [inviteeNames addObject:[person objectForKey:WD_modelKey_User_name]];
  }
  self.peopleField.text = [inviteeNames componentsJoinedByString:@", "];
}


- (void)composeDidSucceed {
  [self transitionOutOfFullScreen];
}

- (void)composeDidFail {
  self.pending.text = WD_comp_failure;
  [self.pending sizeToFit];
  double delayInSeconds = 2.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //code to be executed on the main queue after delay
    [self transitionOutOfFullScreen];
  });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Target methods

- (void)didTapOnCancel {
  if (!self.isFullScreen) {
    return;
  }

  [self transitionOutOfFullScreen];
}

- (void)didTapOnSubmit {
  // TODO: Add validation hints
  if ([self.invitees count] < 1){
    return;
  }
  if ([self.messageField.text isEqualToString:WD_comp_messageFieldPlaceholder]) {
    return;
  }

  [self.delegate createEventWithPeople:self.invitees message:self.messageField.text];
  [self transitionToPendingMode];
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
    return NO;
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
    }
  }
  return NO;
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
#pragma mark  ABPeoplePickerNavigationControllerDelegate methods

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
  ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
  NSInteger phoneNumbersCount = ABMultiValueGetCount(phoneNumbers);

  if (phoneNumbersCount < 1) {
    // TODO: if they have no phone numbers, do something meaningful here.
    return NO;
  } else if (phoneNumbersCount > 1) {
    return YES;
  }
  
  NSString *name  = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
  NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
  NSString *sanitizedPhone = [self.peopleModel sanitizePhoneNumber:phone];
  
  [self.invitees addObject:@{ WD_modelKey_User_name  : name,
                              WD_modelKey_User_phone : sanitizedPhone }];
  [self listInvitees];
  [self hidePeopleVCWithAnimation:YES];
  [self.peopleField becomeFirstResponder];
  return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
  
  if (property == kABPersonPhoneProperty) {
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex phoneNumberIndex = ABMultiValueGetIndexForIdentifier(phoneNumbers, identifier);
    
    NSString *name  = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
    NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, phoneNumberIndex);
    NSString *sanitizedPhone = [self.peopleModel sanitizePhoneNumber:phone];
    
    [self.invitees addObject:@{ WD_modelKey_User_name  : name,
                                WD_modelKey_User_phone : sanitizedPhone }];
    [self listInvitees];
    [self hidePeopleVCWithAnimation:YES];
    [peoplePicker popToRootViewControllerAnimated:NO];
    [self.peopleField becomeFirstResponder];
  }
  
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

    [_submitButton setTitle:WD_comp_submitButton forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor grayColor]  forState:UIControlStateHighlighted];
//    [_submitButton setShowsTouchWhenHighlighted:YES];
  }
  return _submitButton;
}

- (UIButton *)contactsChooserButton {
  if (!_contactsChooserButton) {
    _contactsChooserButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [_contactsChooserButton addTarget:self
                               action:@selector(presentPeopleVC)
                     forControlEvents:UIControlEventTouchUpInside];
    _contactsChooserButton.tintColor = [UIColor whiteColor];
  }
  return _contactsChooserButton;
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
- (UILabel *)pending {
  if (!_pending) {
    _pending = [[UILabel alloc] init];
    _pending.text = WD_comp_pending;
    _pending.textAlignment = NSTextAlignmentCenter;
    _pending.textColor = [UIColor whiteColor];
    _pending.font = [UIFont fontWithName:WD_comp_pendingFont size:WD_comp_pendingSize];
    _pending.numberOfLines = 3;
    [_pending sizeToFit];
  }
  return _pending;
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
