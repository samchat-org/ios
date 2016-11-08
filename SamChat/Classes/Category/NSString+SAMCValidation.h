//
//  NSString+SAMCValidation.h
//  SamChat
//
//  Created by HJ on 11/5/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SAMCValidation)

- (BOOL)samc_isValidEmail;
- (BOOL)samc_isValidCellphone;
- (BOOL)samc_isValidVerificationCode;
- (BOOL)samc_isValidPassword;
- (BOOL)samc_isValidUsername;
- (BOOL)samc_isValidTeamname;

@end
