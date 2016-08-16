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
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    deviceId  = [deviceId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (deviceId.length <= 6) {
        DDLogError(@"get device id error");
        return @"AABBCC";
    }
    deviceId = [deviceId substringWithRange:NSMakeRange(deviceId.length-6,6)];
    DDLogDebug(@"device id: %@", deviceId);
    deviceId = @"CCDDEE"; // TODO: delete, for test
    return deviceId;
}

@end
