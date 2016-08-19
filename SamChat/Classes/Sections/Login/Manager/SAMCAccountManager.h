//
//  SAMCAccountManager.h
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESLoginManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SAMCLoginManagerDelegate <NSObject>

@optional

- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType;

- (void)onLogin:(NIMLoginStep)step;

- (void)onAutoLoginFailed:(NSError *)error;

- (void)onMultiLoginClientsChanged;

@end


@interface SAMCAccountManager : NSObject

+ (instancetype)sharedManager;

- (void)registerCodeRequestWithCountryCode:(NSString *)countryCode
                                 cellPhone:(NSString *)cellPhone
                                completion:(void (^)(NSError * __nullable error))completion;
- (void)findPWDCodeRequestWithCountryCode:(NSString *)countryCode
                                cellPhone:(NSString *)cellPhone
                               completion:(void (^)(NSError * __nullable error))completion;

- (void)registerCodeVerifyWithCountryCode:(NSString *)countryCode
                                cellPhone:(NSString *)cellPhone
                               verifyCode:(NSString *)verifyCode
                               completion:(void (^)(NSError * __nullable error))completion;
- (void)findPWDCodeVerifyWithCountryCode:(NSString *)countryCode
                               cellPhone:(NSString *)cellPhone
                              verifyCode:(NSString *)verifyCode
                              completion:(void (^)(NSError * __nullable error))completion;

- (void)registerWithCountryCode:(NSString *)countryCode
                      cellPhone:(NSString *)cellPhone
                     verifyCode:(NSString *)verifyCode
                       username:(NSString *)username
                       password:(NSString *)password
                     completion:(void (^)(NSError * __nullable error))completion;
- (void)findPWDUpdateWithCountryCode:(NSString *)countryCode
                           cellPhone:(NSString *)cellPhone
                          verifyCode:(NSString *)verifyCode
                            password:(NSString *)password
                          completion:(void (^)(NSError * __nullable error))completion;

- (void)loginWithCountryCode:(NSString *)countryCode
                     account:(NSString *)account
                    password:(NSString *)password
                  completion:(void (^)(NSError * __nullable error))completion;

- (void)logout:(void (^)(NSError * __nullable error))completion;

- (void)loginNetEaseUsername:(NSString *)username
                      userId:(NSString *)userId
                       token:(NSString *)token
                  completion:(void (^)(NSError *error))completion;

- (void)autoLogin:(LoginData *)loginData;

- (void)kickOtherClient:(NIMLoginClient *)client
             completion:(NIMLoginHandler)completion;

- (NSString *)currentAccount;

- (BOOL)isLogined;

- (NSArray *)currentLoginClients;

- (void)addDelegate:(id<SAMCLoginManagerDelegate>)delegate;

- (void)removeDelegate:(id<SAMCLoginManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
