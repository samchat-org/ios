//
//  SAMCUtils.h
//  SamChat
//
//  Created by HJ on 11/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCUtils : NSObject

+ (BOOL)isValidCellphone:(NSString *)cellphone;
+ (BOOL)isValidVerificationCode:(NSString *)code;
+ (BOOL)isValidPassword:(NSString *)password;

@end
