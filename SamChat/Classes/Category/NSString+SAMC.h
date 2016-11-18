//
//  NSString+SAMC.h
//  SamChat
//
//  Created by HJ on 11/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SAMC)

- (NSString *)samc_MD5String;

- (BOOL)samc_isValidEmail;
- (BOOL)samc_isValidCellphone;
- (BOOL)samc_isValidVerificationCode;
- (BOOL)samc_isValidPassword;
- (BOOL)samc_isValidUsername;
- (BOOL)samc_isValidTeamname;
- (BOOL)samc_isValidSamchatId;

@end
