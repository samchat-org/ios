//
//  SAMCUserInfo.m
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfo.h"
#import "SAMCServerAPIMacro.h"

@implementation SAMCUserInfo

+ (instancetype)userInfoFromDict:(NSDictionary *)infoDict
{
    SAMCUserInfo *info = [[SAMCUserInfo alloc] init];
    info.uniqueId = infoDict[SAMC_ID];
    info.username = infoDict[SAMC_USERNAME];
    info.countryCode = [NSString stringWithFormat:@"%@",[infoDict valueForKey:SAMC_COUNTRYCODE]];;
    info.cellPhone = infoDict[SAMC_CELLPHONE];
    info.email = infoDict[SAMC_EMAIL];
    info.address = infoDict[SAMC_ADDRESS];
    info.usertype = infoDict[SAMC_TYPE];
    info.avatar = [infoDict valueForKeyPath:SAMC_AVATAR_THUMB];
    info.avatarOriginal = [infoDict valueForKeyPath:SAMC_AVATAR_ORIGIN];
    info.lastupdate = infoDict[SAMC_LASTUPDATE];
    info.spInfo = [SAMCSamProsInfo spInfoFromDict:infoDict[SAMC_SAM_PROS_INFO]];
    return info;
}

- (SAMCSPBasicInfo *)spBasicInfo
{
    return [SAMCSPBasicInfo infoOfUser:[_uniqueId integerValue]
                              username:_username
                                avatar:_avatar
                              blockTag:NO
                          favouriteTag:NO
                              category:_spInfo.serviceCategory];
}

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