//
//  SAMCServerAPI.h
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCServerAPIMacro.h"

typedef NS_ENUM(NSInteger,SAMCAdvertisementType) {
    SAMCAdvertisementTypeText,
    SAMCAdvertisementTypeImage
};

typedef NS_ENUM(NSInteger,SAMCQueryAccurateUserType) {
    SAMCQueryAccurateUserTypeCellPhone,
    SAMCQueryAccurateUserTypeUniqueId,
    SAMCQueryAccurateUserTypeUsername
};

@interface SAMCServerAPI : NSObject

#pragma mark - Register
+ (NSDictionary *)registerCodeRequestWithCountryCode:(NSString *)countryCode
                                           cellPhone:(NSString *)cellPhone;

+ (NSDictionary *)registerCodeVerifyWithCountryCode:(NSString *)countryCode
                                          cellPhone:(NSString *)cellPhone
                                         verifyCode:(NSString *)verifyCode;

+ (NSDictionary *)registerWithCountryCode:(NSString *)countryCode
                                cellPhone:(NSString *)cellPhone
                               verifyCode:(NSString *)verifyCode
                                 username:(NSString *)username
                                 password:(NSString *)password;

+ (NSDictionary *)loginWithCountryCode:(NSString *)countryCode
                               account:(NSString *)account
                              password:(NSString *)password;

+ (NSDictionary *)logout:(NSString *)account;

+ (NSDictionary *)createSamPros:(NSDictionary *)info;

+ (NSDictionary *)findPWDCodeRequestWithCountryCode:(NSString *)countryCode
                                          cellPhone:(NSString *)cellPhone;
+ (NSDictionary *)findPWDCodeVerifyWithCountryCode:(NSString *)countryCode
                                         cellPhone:(NSString *)cellPhone
                                        verifyCode:(NSString *)verifyCode;
+ (NSDictionary *)findPWDUpdateWithCountryCode:(NSString *)countryCode
                                     cellPhone:(NSString *)cellPhone
                                    verifyCode:(NSString *)verifyCode
                                      password:(NSString *)password;

+ (NSDictionary *)updatePWDFrom:(NSString *)currentPWD
                             to:(NSString *)changePWD;

+ (NSDictionary *)sendQuestion:(NSString *)question
                      location:(NSDictionary *)location;
+ (NSDictionary *)queryPopularRequest:(NSInteger)count;

+ (NSDictionary *)follow:(BOOL)isFollow
         officialAccount:(NSString *)userId;

+ (NSDictionary *)block:(BOOL)blockFlag
                   user:(NSString *)userId;

+ (NSDictionary *)queryFuzzyUser:(NSString *)key;
+ (NSDictionary *)queryAccurateUser:(id)key type:(SAMCQueryAccurateUserType)type;
+ (NSDictionary *)queryUsers:(NSArray<NSString *> *)userIds;
+ (NSDictionary *)queryWithoutToken:(NSString *)username;

+ (NSDictionary *)queryPublicWithKey:(NSString *)key
                        currentCount:(NSInteger)count
                            location:(NSDictionary *)location;

+ (NSDictionary *)queryFollowList;
+ (NSDictionary *)queryContactList:(SAMCContactListType)type;

+ (NSDictionary *)addOrRemove:(BOOL)isAdd
                      contact:(NSString *)userId
                         type:(SAMCContactListType)type;

+ (NSDictionary *)sendInviteMsg:(NSArray *)phones;

+ (NSDictionary *)writeAdvertisementType:(SAMCAdvertisementType)type
                                 content:(NSString *)content
                               messageId:(NSString *)messageId;

+ (NSDictionary *)updateAvatar:(NSString *)url;

+ (NSDictionary *)getPlacesInfo:(NSString *)key;

+ (NSDictionary *)queryStateDate;

+ (NSDictionary *)updateProfile:(NSDictionary *)profile;

+ (NSDictionary *)editCellPhoneCodeRequestWithCountryCode:(NSString *)countryCode
                                                cellPhone:(NSString *)cellPhone;

+ (NSDictionary *)editCellPhoneUpdateWithCountryCode:(NSString *)countryCode
                                           cellPhone:(NSString *)cellPhone
                                          verifyCode:(NSString *)verifyCode;

+ (NSDictionary *)updateQuestionNotify:(BOOL)needNotify;

+ (NSDictionary *)createSamchatId:(NSString *)samchatId;

@end
