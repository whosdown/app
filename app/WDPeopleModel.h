//
//  WDPeopleModel.h
//  wd
//
//  Created by Joseph Schaffer on 3/13/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface WDPeopleModel : NSObject

@property ABAddressBookRef addressBook;

- (void)setUp;

- (NSString *)fullNameForPerson:(ABRecordRef)person;


@end
