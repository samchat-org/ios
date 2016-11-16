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
    deviceId = @"CCDDEE"; // TODO: delete, for test
    DDLogDebug(@"device id: %@", deviceId);
    return deviceId;
}

+ (NSString *)deviceInfo
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceInfo = [NSString stringWithFormat:@"iOS-%@ %@",device.systemName,device.systemVersion];
    return deviceInfo;
}

+ (NSString *)appInfo
{
    NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
//    NSString *appName = [dic objectForKey:@"CFBundleName"];
//    NSString *appVersion = [dic valueForKey:@"CFBundleVersion"];
//    return [NSString stringWithFormat:@"%@ %@", appName, appVersion];
    return [dic valueForKey:@"CFBundleVersion"];
}

@end
