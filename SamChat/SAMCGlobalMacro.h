//
//  SAMCGlobalMacro.h
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#ifndef SAMCGlobalMacro_h
#define SAMCGlobalMacro_h

#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
#define UIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight                             [UIScreen mainScreen].bounds.size.height
#define UISreenWidthScale   UIScreenWidth / 320


#define UICommonTableBkgColor UIColorFromRGB(0xECEDF0)
#define Message_Font_Size   14        // 普通聊天文字大小
#define Notification_Font_Size   10   // 通知文字大小
#define Chatroom_Message_Font_Size 16 // 聊天室聊天文字大小


#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#pragma mark - UIColor宏定义
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

#define SAMC_MAIN_DARKCOLOR         UIColorFromRGB(0x1D4D73)
#define SAMC_MAIN_LIGHTCOLOR        UIColorFromRGB(0x9BAFBF)

#define SAMC_COLOR_INGRABLUE        UIColorFromRGB(0x1D4D73)
#define SAMC_COLOR_SKYBLUE          UIColorFromRGB(0x2EBDEF)
#define SAMC_COLOR_GREEN            UIColorFromRGB(0x67D45F)
#define SAMC_COLOR_LEMMON           UIColorFromRGB(0xD1F43B)
#define SAMC_COLOR_LAKE             UIColorFromRGB(0x2676B6)
#define SAMC_COLOR_DARKBLUE         UIColorFromRGB(0x1B3257)
#define SAMC_COLOR_INK              UIColorFromRGB(0x13243F)
#define SAMC_COLOR_LIME             UIColorFromRGB(0x0CAC0C)
#define SAMC_COLOR_RED              UIColorFromRGB(0xDC374B)
#define SAMC_COLOR_LIGHTGREY        UIColorFromRGB(0xECEDF0)
#define SAMC_COLOR_LIMEGREY         UIColorFromRGB(0xD8DCE2)
#define SAMC_COLOR_GREY             UIColorFromRGB(0xA2AEBC)
#define SAMC_COLOR_CHARCOAL         UIColorFromRGB(0x030303)
#define SAMC_COLOR_DARKBLUE_GRADIENT_DARK       UIColorFromRGB(0x1B3257)
#define SAMC_COLOR_DARKBLUE_GRADIENT_LIGHT      UIColorFromRGB(0x1D4D73)
#define SAMC_COLOR_LIGHTBLUE_GRADIENT_DARK      UIColorFromRGB(0x2676B6)
#define SAMC_COLOR_LIGHTBLUE_GRADIENT_LIGHT     UIColorFromRGB(0x2EBDEF)
#define SAMC_COLOR_GRASSFIELD_GRADIENT_DARK     UIColorFromRGB(0x20CB9D)
#define SAMC_COLOR_GRASSFIELD_GRADIENT_LIGHT    UIColorFromRGB(0x80E22F)
#define SAMC_COLOR_HORIZON_GRADIENT_DARK        UIColorFromRGB(0x2EBDEF)
#define SAMC_COLOR_HORIZON_GRADIENT_LIGHT       UIColorFromRGB(0xD1F43B)

#define SAMC_COLOR_BODY_MID         UIColorFromRGBA(0x13243F, 0.6)
#define SAMC_COLOR_INPUTTEXT_HINT   UIColorFromRGBA(0x13243F, 0.5)

#define SAMC_COLOR_RGB_GREEN        0x67D45F
#define SAMC_COLOR_RGB_INK          0x13243F
#define SAMC_COLOR_RGB_LEMMON       0xD1F43B
#define SAMC_COLOR_RGB_LAKE         0x2676B6
#define SAMC_COLOR_RGB_INGRABLUE    0x1D4D73

#define SAMC_COLOR_GREEN_BUTTON_ACTIVE      SAMC_COLOR_GREEN
#define SAMC_COLOR_GREEN_BUTTON_INACTIVE    UIColorFromRGBA(0x67D45F, 0.5);

#define SAMC_COLOR_TEXT_HINT_DARK       UIColorFromRGBA(0xFFFFFF, 0.5)
#define SAMC_COLOR_TEXT_HINT_LIGHT      UIColorFromRGBA(0x13243F, 0.5)

#define SAMC_FONT_Ingra_Book            @"Ingra-Regular7"
#define SAMC_FONT_Ingra_Demo_Bold       @"IngraDemo-Bold"
#define SAMC_FONT_Ingra_Extra_Bold      @"Ingra-Regular8"
#define SAMC_FONT_Ingra_Hair            @"Ingra-Hair"
#define SAMC_FONT_Ingra_Light           @"Ingra-Regular2"
#define SAMC_FONT_Ingra_Medium          @"Ingra-Regular4"
#define SAMC_FONT_Ingra_Regular         @"Ingra-Regular"
#define SAMC_FONT_Ingra_SemiBold        @"Ingra-Regular5"
#define SAMC_FONT_Ingra_Thin            @"Ingra-Regular3"
#define SAMC_FONT_Ingra_Bold            @"Ingra-Bold"

#define SAMCFontIngraBookOfSize(sizeValue)       [UIFont fontWithName:SAMC_FONT_Ingra_Book size:sizeValue]
#define SAMCFontIngraDemoBoldOfSize(sizeValue)   [UIFont fontWithName:SAMC_FONT_Ingra_Demo_Bold size:sizeValue]
#define SAMCFontIngraExtraBoldOfSize(sizeValue)  [UIFont fontWithName:SAMC_FONT_Ingra_Extra_Bold size:sizeValue]
#define SAMCFontIngraHairOfSize(sizeValue)       [UIFont fontWithName:SAMC_FONT_Ingra_Hair size:sizeValue]
#define SAMCFontIngraLightOfSize(sizeValue)      [UIFont fontWithName:SAMC_FONT_Ingra_Light size:sizeValue]
#define SAMCFontIngraMediumOfSize(sizeValue)     [UIFont fontWithName:SAMC_FONT_Ingra_Medium size:sizeValue]
#define SAMCFontIngraRegularOfSize(sizeValue)    [UIFont fontWithName:SAMC_FONT_Ingra_Regular size:sizeValue]
#define SAMCFontIngraSemiBoldOfSize(sizeValue)   [UIFont fontWithName:SAMC_FONT_Ingra_SemiBold size:sizeValue]
#define SAMCFontIngraThinOfSize(sizeValue)       [UIFont fontWithName:SAMC_FONT_Ingra_Thin size:sizeValue]
#define SAMCFontIngraBoldOfSize(sizeValue)       [UIFont fontWithName:SAMC_FONT_Ingra_Bold size:sizeValue]

#define dispatch_sync_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


static inline void method_execute_frequency(id obj ,SEL selecter, NSTimeInterval timeInterval){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [obj performSelector:selecter withObject:nil afterDelay:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onceToken = 0;
        });
    });
}

#define SAMCTopBarHeight ([UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height)

#ifdef DEBUG
#define TICK  NSDate *startTime = [NSDate date]
#define TOCK  NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])
#else
#define TICK
#define TOCK
#endif

#define MESSAGE_EXT_FROM_USER_MODE_KEY          @"msg_from"
#define MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM @(0)
#define MESSAGE_EXT_FROM_USER_MODE_VALUE_SP     @(1)

#define MESSAGE_EXT_UNREAD_FLAG_KEY         @"unread_flag"
#define MESSAGE_EXT_UNREAD_FLAG_YES         @(YES)
#define MESSAGE_EXT_UNREAD_FLAG_NO          @(NO)

#define MESSAGE_EXT_QUESTION_ID_KEY         @"quest_id"
#define MESSAGE_EXT_PUBLIC_ID_KEY           @"adv_id"

#define MESSAGE_EXT_SAVE_FLAG_KEY           @"save_flag"
#define MESSAGE_EXT_SAVE_FLAG_YES           @(YES)
#define MESSAGE_EXT_SAVE_FLAG_NO            @(NO)

#define CALL_MESSAGE_EXTERN_FROM_CUSTOM     @"customer"
#define CALL_MESSAGE_EXTERN_FROM_SP         @"sp"

#define SAMC_QR_ADDCONTACT_PREFIX           @"Samchat:"

typedef NS_ENUM(NSInteger,SAMCUserModeType) {
    SAMCUserModeTypeCustom,
    SAMCUserModeTypeSP,
    SAMCUserModeTypeUnknow
};

typedef NS_ENUM(NSInteger,SAMCQuestionSessionType) {
    SAMCQuestionSessionTypeSend,
    SAMCQuestionSessionTypeReceived
};

typedef NS_ENUM(NSInteger,SAMCReceivedQuestionStatus) {
    SAMCReceivedQuestionStatusNew,
    SAMCReceivedQuestionStatusInserted,
    SAMCReceivedQuestionStatusResponsed
};

typedef NS_ENUM(NSInteger,SAMCUserType) {
    SAMCUserTypeCustom,
    SAMCuserTypeSamPros
};

typedef NS_ENUM(NSInteger,SAMCContactListType) {
    SAMCContactListTypeServicer,
    SAMCContactListTypeCustomer
};

#endif /* SAMCGlobalMacro_h */
