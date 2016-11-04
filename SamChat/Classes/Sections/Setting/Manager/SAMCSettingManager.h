//
//  SAMCSettingManager.h
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMCSettingManager : NSObject

+ (instancetype)sharedManager;

- (void)createSamPros:(NSDictionary *)info
           completion:(void (^)(NSError * __nullable error))completion;

- (void)updateAvatar:(NSString *)url
          completion:(void (^)(SAMCUser * __nullable user, NSError * __nullable error))completion;

- (void)updateProfile:(NSDictionary *)profileDict
           completion:(void (^)(NSError * __nullable error))completion;

- (void)editCellPhoneCodeRequestWithCountryCode:(NSString *)countryCode
                                      cellPhone:(NSString *)cellPhone
                                     completion:(void (^)(NSError * __nullable error))completion;

- (void)editCellPhoneUpdateWithCountryCode:(NSString *)countryCode
                                 cellPhone:(NSString *)cellPhone
                                verifyCode:(NSString *)verifyCode
                                completion:(void (^)(NSError * __nullable error))completion;

@end

NS_ASSUME_NONNULL_END