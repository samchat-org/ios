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


#define UICommonTableBkgColor UIColorFromRGB(0xe4e7ec)
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

#endif /* SAMCGlobalMacro_h */
