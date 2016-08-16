//
//  SAMCServerAPI.m
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServerAPI.h"
#import "SAMCDeviceUtil.h"

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
{
    cellPhone = cellPhone ?:@"";
    countryCode = countryCode ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_REGISTER_CODE_REQUEST};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_DEVICEID:deviceId};
    NSDictionary *data = @{SAMC_HEADER:header,SAMC_BODY:body};
    return [SAMCServerAPI generateUrlStringWithAPI:SAMC_API_REGISTER_CODE_REQUEST data:data];
}

//{
//    "header":
//    {
//        "action" : "signup-code-verify",
//    },
//    "body":
//    {
//        "countrycode" :
//        "cellphone"	: “”
//        "verifycode" : “”
//        "deviceid" :””
//    }
//}
+ (NSString *)urlRegisterCodeVerifyWithCountryCode:(NSString *)countryCode
                                         cellPhone:(NSString *)cellPhone
                                        verifyCode:(NSString *)verifyCode
{
    countryCode = countryCode ?:@"";
    cellPhone = cellPhone ?:@"";
    verifyCode = verifyCode ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_SIGNUP_CODE_VERIFY};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_VERIFYCODE:verifyCode,
                           SAMC_DEVICEID:deviceId};
    NSDictionary *data = @{SAMC_HEADER:header,SAMC_BODY:body};
    return [SAMCServerAPI generateUrlStringWithAPI:SAMC_API_SIGNUP_CODE_VERIFY data:data];
}

//{
//    "header":
//    {
//        "action" : "register"
//    },
//    "body" :
//    {
//        “countrycode”		:86
//        “cellphone”		:“1381196123”
//        “verifycode”      : 332682
//        “username”		:”Kevin Dong”
//        “pwd”             :”123456”
//        “deviceid”		:”14EF65” //(IMEI/MEID last 6 byte)
//    }
//}
+ (NSString *)registerWithCountryCode:(NSString *)countryCode
                            cellPhone:(NSString *)cellPhone
                           verifyCode:(NSString *)verifyCode
                             username:(NSString *)username
                             password:(NSString *)password
{
    countryCode = countryCode ?:@"";
    cellPhone = cellPhone ?:@"";
    verifyCode = verifyCode ?:@"";
    username = username ?:@"";
    password = password ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_REGISTER};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_VERIFYCODE:verifyCode,
                           SAMC_USERNAME:username,
                           SAMC_PWD:password,
                           SAMC_DEVICEID:deviceId};
    NSDictionary *data = @{SAMC_HEADER:header,SAMC_BODY:body};
    return [SAMCServerAPI generateUrlStringWithAPI:SAMC_API_USER_REGISTER data:data];
}

//{
//    "header":
//    {
//        “action”: “login”
//    },
//    "body" :
//    {
//        “countrycode”	:86
//        “account”		:“1381196123”
//        “pwd”			:”123456”
//        “deviceid”	:”14EF65” //(IMEI/MEID last 6 byte)
//    }
//}
+ (NSString *)loginWithCountryCode:(NSString *)countryCode
                           account:(NSString *)account
                          password:(NSString *)password
{
    countryCode = countryCode ?:@"";
    account = account ?:@"";
    password = password ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_LOGIN};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_ACCOUNT:account,
                           SAMC_PWD:password,
                           SAMC_DEVICEID:deviceId};
    NSDictionary *data = @{SAMC_HEADER:header,SAMC_BODY:body};
    return [SAMCServerAPI generateUrlStringWithAPI:SAMC_API_USER_LOGIN data:data];
}

//{
//    "header":
//    {
//        "action" : "logout",
//        "token": ""
//    },
//    "body" :
//    {
//    }
//}
+ (NSString *)logout:(NSString *)account
               token:(NSString *)token
{
    account = account ?:@"";
    token = token ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_LOGOUT,SAMC_TOKEN:token};
    NSDictionary *body = @{};
    NSDictionary *data = @{SAMC_HEADER:header,SAMC_BODY:body};
    return [SAMCServerAPI generateUrlStringWithAPI:SAMC_API_USER_LOGOUT data:data];
}

@end
