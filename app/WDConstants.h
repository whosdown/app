//
//  WDConstants.h
//  app
//
//  Created by Joseph Schaffer on 2/21/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#ifndef app_WDConstants_h
#define app_WDConstants_h

/******* Utils *******/

#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/******* Style *******/

#define WD_FONT_ui    @"HelveticaNeue"
#define WD_FONT_brand @"DINAlternate-Bold"

#define WD_UIColor_green UIColorFromHex(0x81CD8A)


/*
 * WDVerify Styles
 */

#define WD_veri_title       @"Who's Down"
#define WD_veri_titleFont   WD_FONT_brand
#define WD_veri_titleSize   45

#define WD_veri_tagLine     @"Find out who's down to ______"
#define WD_veri_tagLineFont WD_FONT_brand
#define WD_veri_tagLineSize 20

#define WD_veri_fieldFont         WD_FONT_brand
#define WD_veri_fieldSize         WD_veri_tagLineSize
#define WD_veri_nameFieldPlaceholder  @"Name"
#define WD_veri_phoneFieldPlaceholder @"Phone number"

#define WD_veri_pending     @"a text message should arrive shortly to verify your phone number."
#define WD_veri_pendingFont WD_FONT_brand
#define WD_veri_pendingSize 20

#define WD_veri_undo        @"try again"
#define WD_veri_undoFont    WD_FONT_brand
#define WD_veri_undoSize    20

/*
 * WDCompose Styles
 */

#define WD_comp_title     WD_veri_title
#define WD_comp_titleFont WD_FONT_brand
#define WD_comp_titleSize 22

#define WD_comp_newEventTitle     @"new hangout"
#define WD_comp_newEventTitleFont WD_FONT_ui
#define WD_comp_newEventTitleSize WD_comp_titleSize


#define WD_comp_fieldFont WD_FONT_ui
#define WD_comp_fieldSize 15

#define WD_comp_peopleFieldPlaceholder @"people to ask..."
#define WD_comp_messageFieldPlaceholder @"\"who's down to...\""


/******* Data Keys *******/

#define WD_localKey_User_id         @"WDUserIdKey"      // Type: NSString
#define WD_localKey_User_verifyCode @"WDUserVerifyCode" // Type: NSString
#define WD_localKey_User_object     @"WDUserIdKey"      // Type: NSDictionary

#define WD_modelKey_SUCCESS_DATA    @"data"
#define WD_modelKey_FAILURE_DATA    @"error"

#define WD_modelKey_User            @"user"
#define WD_modelKey_User_id         @"_id"
#define WD_modelKey_User_name       @"name"
#define WD_modelKey_User_phone      @"phone"
#define WD_modelKey_User_verifyCode @"code"
#define WD_modelKey_User_isVerified @"isVerified"

#define WD_modelKey_Verify_code @"code"
#define WD_modelKey_Verify_id   @"userId"


typedef enum WDInteractionModes {
  WDInteractionVerify,
  WDInteractionVerifyConclude,
  WDInteractionNone
} WDInteractionMode;

#endif
