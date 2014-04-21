//
//  WDPeopleModel.m
//  wd
//
//  Created by Joseph Schaffer on 3/13/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDPeopleModel.h"

@interface WDPeopleModel ()

@end

@implementation WDPeopleModel

- (id)init {
  self = [super init];
  if (self) {
    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
  }
  return self;
}

- (void)setUp {
  switch (ABAddressBookGetAuthorizationStatus()) {
      // Update our UI if the user has granted access to their Contacts
    case  kABAuthorizationStatusAuthorized:
      [self accessGrantedForAddressBook];
      break;
      // Prompt the user for access to Contacts if there is no definitive answer
    case  kABAuthorizationStatusNotDetermined :
      [self requestAddressBookAccess];
      break;
      // Display a message if the user has denied or restricted access to Contacts
    case  kABAuthorizationStatusDenied:
    case  kABAuthorizationStatusRestricted:
    {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
                                                      message:@"Please go into the iOS settings and "
                            "give Who's Down permission to access your "
                            "contacts.\n\nLocated in\nSettings > Privacy > Contacts"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];
    }
      break;
    default:
      break;
  }

}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess {
  
  ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                           {
                                             if (granted)
                                             {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self accessGrantedForAddressBook];
                                                 
                                               });
                                             }
                                           });
}

// This method is called when the user has granted access to their address book data.
-(void)accessGrantedForAddressBook {
  // Load data from the plist file
}

- (NSString *) fullNameForPerson:(ABRecordRef)person {
  NSString *firstName =
  (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
  NSString *lastName =
  (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
  NSString *personName;
  if (firstName && lastName) {
    personName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
  } else if (firstName) {
    personName = firstName;
  } else if (lastName) {
    personName = lastName;
  }
  return personName;
}

- (NSString *)sanitizePhoneNumber:(NSString *)phoneNumber {
  NSString *sanitizedPhoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
  if ([sanitizedPhoneNumber length] == 10) {
    return [NSString stringWithFormat:@"+1%@", sanitizedPhoneNumber];
  } else {
    return [NSString stringWithFormat:@"+%@", sanitizedPhoneNumber];
  }
}

@end
