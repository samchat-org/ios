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
+ (NSDictionary *)registerCodeRequestWithCountryCode:(NSString *)countryCode
                                           cellPhone:(NSString *)cellPhone
{
    cellPhone = cellPhone ?:@"";
    countryCode = countryCode ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_REGISTER_CODE_REQUEST};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_DEVICEID:deviceId};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
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
+ (NSDictionary *)registerCodeVerifyWithCountryCode:(NSString *)countryCode
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
    return @{SAMC_HEADER:header,SAMC_BODY:body};
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
+ (NSDictionary *)registerWithCountryCode:(NSString *)countryCode
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
    return @{SAMC_HEADER:header,SAMC_BODY:body};
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
+ (NSDictionary *)loginWithCountryCode:(NSString *)countryCode
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
    return @{SAMC_HEADER:header,SAMC_BODY:body};
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
+ (NSDictionary *)logout:(NSString *)account
                   token:(NSString *)token
{
    account = account ?:@"";
    token = token ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_LOGOUT,SAMC_TOKEN:token};
    NSDictionary *body = @{};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "appkey-get",
//        "token": ""
//    },
//    "body" :
//    {
//    }
//}
+ (NSDictionary *)getAppKey:(NSString *)token
{
    token = token ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_APPKEY_GET,SAMC_TOKEN:token};
    NSDictionary *body = @{};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "create-sam-pros",
//        "token": "token"
//    },
//    "body":
//    {
//        "company_name"	: “”
//        "service_category"	: ””
//        "service_description"	: “”
//        “countrycode”: // option
//        “phone”: // option
//        “email”: // option
//        "location" :{
//            "location_info":{ //option
//                “longitude”:
//                “latitude”
//            } 
//            "place_id": " "//option
//            "address": " "//option
//        }
//    }
//}
+ (NSDictionary *)createSamPros:(NSDictionary *)info
                          token:(NSString *)token
{
    NSAssert(info != nil, @"create sam pros info should not be nil");
    token = token ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_CREATE_SAM_PROS,SAMC_TOKEN:token};
    return @{SAMC_HEADER:header,SAMC_BODY:info};
}


@end
