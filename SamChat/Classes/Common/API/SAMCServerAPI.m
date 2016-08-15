//
//  SAMCServerAPI.m
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServerAPI.h"

@implementation SAMCServerAPI

+ (NSString *)generateUrlStringWithAPI:(NSString *)api data:(NSDictionary *)data
{
    NSString *urlStr = SAMC_API_PREFIX;
    if ([NSJSONSerialization isValidJSONObject:data]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData
                                               encoding:NSUTF8StringEncoding];
        urlStr = [NSString stringWithFormat:@"%@%@?data=%@",SAMC_API_PREFIX, api, json];
    }
    return [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

//{
//    "header":
//    {
//        "action" : "register-code-request",
//    },
//    "body":
//    {
//        "countrycode" : “”
//        "cellphone"	: “”
//        "deviceid"	: “”
//    }
//}
+ (NSString *)urlRegisterCodeRequestWithCountryCode:(NSString *)countryCode
                                          cellPhone:(NSString *)cellPhone
                                           deviceId:(NSString *)deviceId
{
    cellPhone = cellPhone ?:@"";
    countryCode = countryCode ?:@"";
    deviceId = deviceId ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_REGISTER_CODE_REQUEST};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_DEVICEID:deviceId};
    NSDictionary *data = @{SAMC_HEADER:header,SAMC_BODY:body};
    return [SAMCServerAPI generateUrlStringWithAPI:SAMC_API_REGISTER_CODE_REQUEST data:data];
}

@end
