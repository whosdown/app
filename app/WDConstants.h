//
//  WDConstants.h
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#ifndef app_WDConstants_h
#define app_WDConstants_h

// Style

#define WD_TITLE         @"Who's Down"
#define WD_TITLE_FONT    @"DINAlternate-Bold"
#define WD_TITLE_SIZE    45

#define WD_TAG_LINE      @"Find out who's down to ______"
#define WD_TAG_LINE_FONT @"DINAlternate-Bold"
#define WD_TAG_LINE_SIZE 20

#define WD_PENDING       @"a text message should arrive shortly to verify your phone number."
#define WD_PENDING_FONT  @"DINAlternate-Bold"
#define WD_PENDING_SIZE  20

#define WD_UNDO          @"try again"
#define WD_UNDO_FONT     @"DINAlternate-Bold"
#define WD_UNDO_SIZE     20

#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define WD_GREEN_COLOR 0x81CD8A


// Data

#define WD_localKey_User_id         @"WDUserIdKey"      // Type: NSString
#define WD_localKey_User_verifyCode @"WDUserVerifyCode" // Type: NSString
#define WD_localKey_User_object     @"WDUserIdKey"      // Type: NSDictionary

#define WD_modelKey_SUCCESS_DATA @"data"
#define WD_modelKey_FAILURE_DATA @"error"

#define WD_modelKey_User            @"user"
#define WD_modelKey_User_id         @"_id"
#define WD_modelKey_User_name       @"name"
#define WD_modelKey_User_phone      @"phone"
#define WD_modelKey_User_verifyCode @"code"
#define WD_modelKey_User_isVerified @"isVerified"

typedef enum WDInteractionModes {
  WDInteractionVerify,
  WDInteractionNone
} WDInteractionMode;

#endif
