//
//  SAMCDeviceUtil.m
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDeviceUtil.h"

@implementation SAMCDeviceUtil

+ (NSString *)deviceId
{
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return idfv;
}

@end
