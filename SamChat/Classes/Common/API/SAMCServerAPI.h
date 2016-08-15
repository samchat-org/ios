//
//  SAMCServerAPI.h
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCServerAPIMacro.h"

@interface SAMCServerAPI : NSObject

#pragma mark - Register
+ (NSString *)urlRegisterCodeRequestWithCountryCode:(NSString *)countryCode
                                          cellPhone:(NSString *)cellPhone;

+ (NSString *)urlRegisterCodeVerifyWithCountryCode:(NSString *)countryCode
                                         cellPhone:(NSString *)cellPhone
                                        verifyCode:(NSString *)verifyCode;

+ (NSString *)registerWithCountryCode:(NSString *)countryCode
                            cellPhone:(NSString *)cellPhone
                           verifyCode:(NSString *)verifyCode
                             username:(NSString *)username
                             password:(NSString *)password;
@end
