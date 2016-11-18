//
//  NSString+SAMC.m
//  SamChat
//
//  Created by HJ on 11/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NSString+SAMC.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SAMC)

- (NSString *)samc_MD5String
{
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (BOOL)samc_isValidEmail
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)samc_isValidCellphone
{
    if ((self.length<6) || (self.length>11)) {
        return false;
    }
    NSString *cellphone = [self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (cellphone.length > 0) {
        return false;
    }
    return true;
}

- (BOOL)samc_isValidVerificationCode
{
    if ([self length] != 4) {
        return false;
    }
    NSString *code = [self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if ([code length] > 0) {
        return false;
    }
    return true;
}

- (BOOL)samc_isValidPassword
{
    NSString *password = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ((password.length<6) || (password.length>32)) {
        return false;
    }
    return true;
}

- (BOOL)samc_isValidUsername
{
    NSString *username = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ((username.length<3) || (username.length>15)) {
        return false;
    }
    return true;
}

- (BOOL)samc_isValidTeamname
{
    NSString *teamname = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (teamname.length) {
        return true;
    }
    return false;
}

- (BOOL)samc_isValidSamchatId
{
    NSString *username = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ((username.length<3) || (username.length>15)) {
        return false;
    }
    return true;
}

@end
