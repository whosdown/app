//
//  WDConstants.h
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#ifndef app_WDConstants_h
#define app_WDConstants_h

#define WD_KEY_USER_ID @"WDUserIdKey" // Type: NSString
#define WD_KEY_USER_OBJECT @"WDUserIdKey" // Type: NSDictionary

#define WD_TITLE_FONT @"DINAlternate-Bold"
#define WD_TITLE @"Who's Down"
#define WD_TAG_LINE @"Find out who's down to ______"
#define WD_TAG_LINE_FONT @"DINAlternate-Bold"

#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define WD_GREEN_COLOR 0x81CD8A

#endif
