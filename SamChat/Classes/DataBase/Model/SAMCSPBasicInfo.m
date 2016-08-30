//
//  SAMCSPBasicInfo.m
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPBasicInfo.h"

@implementation SAMCSPBasicInfo

+ (instancetype)infoOfUser:(NSInteger)uniqueId
                  username:(NSString *)username
                    avatar:(NSString *)avatar
                  blockTag:(BOOL)blockTag
              favouriteTag:(BOOL)favouriteTag
                  category:(NSString *)category
{
    SAMCSPBasicInfo *info = [[SAMCSPBasicInfo alloc] init];
    info.uniqueId = uniqueId;
    info.username = username;
    info.avatar = avatar;
    info.blockTag = blockTag;
    info.favouriteTag = favouriteTag;
    info.spServiceCategory = category;
    return info;
}

@end
