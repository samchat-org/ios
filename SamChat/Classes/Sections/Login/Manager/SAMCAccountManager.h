//
//  SAMCAccountManager.h
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

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

- (void)registerCodeVerifyWithCountryCode:(NSString *)countryCode
                                cellPhone:(NSString *)cellPhone
                               verifyCode:(NSString *)verifyCode
                               completion:(void (^)(NSError * __nullable error))completion;

- (void)registerWithCountryCode:(NSString *)countryCode
                      cellPhone:(NSString *)cellPhone
                     verifyCode:(NSString *)verifyCode
                       username:(NSString *)username
                       password:(NSString *)password
                     completion:(void (^)(NSError * __nullable error))completion;

- (void)loginWithCountryCode:(NSString *)countryCode
                     account:(NSString *)account
                    password:(NSString *)password
                  completion:(void (^)(NSError * __nullable error))completion;

- (void)logout:(void (^)(NSError * __nullable error))completion;

//- (void)signup:(NSString *)account
//      password:(NSString *)password
//     cellphone:(NSString *)cellphone
//   countryCode:(NSNumber *)countrycode
//    completion:(void (^)(NSError *error))completion;
//
//- (void)login:(NSString *)account
//     password:(NSString *)password
//   completion:(void (^)(NSError *error))completion;
//
//- (void)autoLogin:(NSString *)account
//            token:(NSString *)token;
//
//- (void)logout:(void (^)(NSError *error))completion;

- (void)kickOtherClient:(NIMLoginClient *)client
             completion:(NIMLoginHandler)completion;

- (NSString *)currentAccount;

- (BOOL)isLogined;

- (NSArray *)currentLoginClients;

- (void)addDelegate:(id<SAMCLoginManagerDelegate>)delegate;

- (void)removeDelegate:(id<SAMCLoginManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
