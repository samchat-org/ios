//
//  SAMCUtils.m
//  SamChat
//
//  Created by HJ on 11/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUtils.h"

@implementation SAMCUtils

+ (BOOL)isValidCellphone:(NSString *)cellphone
{
    if ((cellphone.length<5) || (cellphone.length>11)) {
        return false;
    }
    cellphone = [cellphone stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (cellphone.length > 0) {
        return false;
    }
    return true;
}

+ (BOOL)isValidVerificationCode:(NSString *)code
{
    if ([code length] != 4) {
        return false;
    }
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if ([code length] > 0) {
        return false;
    }
    return true;
}

+ (BOOL)isValidPassword:(NSString *)password
{
    // TODO: add password checking
    return true;
}

@end
