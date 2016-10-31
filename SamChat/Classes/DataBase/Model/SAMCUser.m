//
//  SAMCUser.m
//  SamChat
//
//  Created by HJ on 9/6/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUser.h"
#import "SAMCServerAPIMacro.h"

@implementation SAMCUser

+ (instancetype)userFromDict:(NSDictionary *)userDict
{
    SAMCUser *user = [[SAMCUser alloc] init];
    user.userId = [NSString stringWithFormat:@"%@",userDict[SAMC_ID]];
    
    SAMCUserInfo *info = [[SAMCUserInfo alloc] init];
    info.username = userDict[SAMC_USERNAME];
    info.countryCode = [NSString stringWithFormat:@"%@",[userDict valueForKey:SAMC_COUNTRYCODE]];;
    info.cellPhone = userDict[SAMC_CELLPHONE];
    info.email = userDict[SAMC_EMAIL];
    info.address = userDict[SAMC_ADDRESS];
    info.usertype = userDict[SAMC_TYPE];
    info.avatar = [userDict valueForKeyPath:SAMC_AVATAR_THUMB];
    info.avatarOriginal = [userDict valueForKeyPath:SAMC_AVATAR_ORIGIN];
    info.lastupdate = userDict[SAMC_LASTUPDATE];
    info.spInfo = [SAMCSamProsInfo spInfoFromDict:userDict[SAMC_SAM_PROS_INFO]];
    
    user.userInfo = info;
    return user;
}

- (SAMCSPBasicInfo *)spBasicInfo
{
    return [SAMCSPBasicInfo infoOfUser:_userId
                              username:_userInfo.username
                                avatar:_userInfo.avatar
                              blockTag:NO
                          favouriteTag:NO
                              category: _userInfo.spInfo.serviceCategory];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\ruserId:%@\rusername:%@",[super description],_userId,_userInfo.username];
}

@end

@implementation SAMCUserInfo

@end

@implementation SAMCSamProsInfo

+ (instancetype)spInfoFromDict:(NSDictionary *)spInfoDict
{
    SAMCSamProsInfo *info = [[SAMCSamProsInfo alloc] init];
    info.companyName = spInfoDict[SAMC_COMPANY_NAME];
    info.serviceCategory = spInfoDict[SAMC_SERVICE_CATEGORY];
    info.serviceDescription = spInfoDict[SAMC_SERVICE_DESCRIPTION];
    info.countryCode = spInfoDict[SAMC_COUNTRYCODE];
    info.phone = spInfoDict[SAMC_PHONE];
    info.email = spInfoDict[SAMC_EMAIL];
    info.address = spInfoDict[SAMC_ADDRESS];
    return info;
}

@end
