//
//  NSString+SAMCValidation.m
//  SamChat
//
//  Created by HJ on 11/5/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NSString+SAMCValidation.h"

@implementation NSString (SAMCValidation)

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

@end
