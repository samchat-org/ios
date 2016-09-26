//
//  SAMCStateDateInfo.m
//  SamChat
//
//  Created by HJ on 9/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCStateDateInfo.h"
#import "SAMCServerAPIMacro.h"

@implementation SAMCStateDateInfo

+ (instancetype)stateDateInfoFromDict:(NSDictionary *)dict
{
    SAMCStateDateInfo *info = [[SAMCStateDateInfo alloc] init];
    info.servicerListVersion = [dict[SAMC_SERVICER_LIST] stringValue];
    info.customerListVersion = [dict[SAMC_CUSTOMER_LIST] stringValue];
    info.followListVersion = [dict[SAMC_FOLLOW_LIST] stringValue];
    return info;
}

@end
