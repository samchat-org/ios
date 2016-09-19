//
//  SAMCServerAPI.m
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServerAPI.h"
#import "SAMCDeviceUtil.h"
#import "NTESLoginManager.h"

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
{
    account = account ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_LOGOUT,SAMC_TOKEN:[SAMCServerAPI token]};
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
{
    NSAssert(info != nil, @"create sam pros info should not be nil");
    NSDictionary *header = @{SAMC_ACTION:SAMC_CREATE_SAM_PROS,SAMC_TOKEN:[SAMCServerAPI token]};
    return @{SAMC_HEADER:header,SAMC_BODY:info};
}

//{
//    "header":
//    {
//        "action" : "findpwd-code-request",
//    },
//    "body":
//    {
//        "countrycode" : “”
//        "cellphone"	: “”
//        "deviceid" :””
//    }
//}
+ (NSDictionary *)findPWDCodeRequestWithCountryCode:(NSString *)countryCode
                                          cellPhone:(NSString *)cellPhone
{
    cellPhone = cellPhone ?:@"";
    countryCode = countryCode ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_FINDPWD_CODE_REQUEST};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_DEVICEID:deviceId};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "findpwd-code-verify",
//    },
//    "body":
//    {
//        "countrycode" :
//        "cellphone"	: “”
//        "verifycode" : “”
//        "deviceid" :””
//    }
//}
+ (NSDictionary *)findPWDCodeVerifyWithCountryCode:(NSString *)countryCode
                                         cellPhone:(NSString *)cellPhone
                                        verifyCode:(NSString *)verifyCode
{
    countryCode = countryCode ?:@"";
    cellPhone = cellPhone ?:@"";
    verifyCode = verifyCode ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_FINDPWD_CODE_VERIFY};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_VERIFYCODE:verifyCode,
                           SAMC_DEVICEID:deviceId};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "findpwd-update",
//    },
//    "body":
//    {
//        "countrycode" :
//        "cellphone"	: “”
//        " verifycode " :
//        "pwd" : “”
//        "deviceid" :””
//    }
//}
+ (NSDictionary *)findPWDUpdateWithCountryCode:(NSString *)countryCode
                                     cellPhone:(NSString *)cellPhone
                                    verifyCode:(NSString *)verifyCode
                                      password:(NSString *)password
{
    countryCode = countryCode ?:@"";
    cellPhone = cellPhone ?:@"";
    verifyCode = verifyCode ?:@"";
    password = password ?:@"";
    NSString *deviceId = [SAMCDeviceUtil deviceId];
    NSDictionary *header = @{SAMC_ACTION:SAMC_FINDPWD_UPDATE};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_VERIFYCODE:verifyCode,
                           SAMC_PWD:password,
                           SAMC_DEVICEID:deviceId};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action": "question",
//        "token":"95189486473904140"
//    },
//    "body":
//    {
//        "opt":[0/1]  0:发送问题   1:TBD,
//        "question" :"aaa"
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
+ (NSDictionary *)sendQuestion:(NSString *)question
                      location:(NSDictionary *)location
{
    question = question ?:@"";
    location = location ?:@{};
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUESTION,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:@(0),
                           SAMC_QUESTION:question,
                           SAMC_LOCATION:location};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "follow",
//        "token"  : "token"
//    },
//    "body":
//    {
//        "opt" :  [0/1]
//        0 :  unfollow
//        1 :  follow
//        "id" : unique_id_in_samchat of Sam-pros
//    }
//}
+ (NSDictionary *)follow:(BOOL)isFollow
         officialAccount:(NSString *)userId;
{
    NSNumber *uniqueId = @([userId integerValue]);
    NSDictionary *header = @{SAMC_ACTION:SAMC_FOLLOW,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:isFollow ? @(1) : @(0),
                           SAMC_ID:uniqueId};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "query-fuzzy",
//        "token": "token"
//    },
//    "body":
//    {
//        "opt":1,   1: Fuzzy User Query
//        "param":
//        {
//            "search_key":""
//        }
//    }
//}
+ (NSDictionary *)queryFuzzyUser:(NSString *)key
{
    key = key ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUERY_FUZZY,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:@(1),
                           SAMC_PARAM:@{SAMC_SEARCH_KEY:key}};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "query-accurate"
//        "token": "token",
//    },
//    "body":
//    {
//        "opt":2,   2: Query by cellphone or username
//        "param":{
//            "type":[0/1/2] 0: cellphone   1:unqiue_id   2: username
//            "cellphone": //option
//            "unique_id ": //option
//            " username": //option
//            
//        }
//    }
//}
+ (NSDictionary *)queryAccurateUser:(NSNumber *)uniqueId
{
    uniqueId = uniqueId ?:@(0);
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUERY_ACCURATE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:@(2),
                           SAMC_PARAM:@{SAMC_TYPE:@(1),SAMC_UNIQUE_ID:uniqueId}};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "query-group"
//        "token": "token",
//    },
//    "body":
//    {
//        "opt":3,   3: Query group users by unique_id
//        "param":{
//            "unique_id":[1,2,3,4,5,6]
//        }
//    }
//}
+ (NSDictionary *)queryUsers:(NSArray<NSString *> *)userIds
{
    userIds = userIds ?:@[];
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUERY_GROUP, SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:@(3),
                           SAMC_PARAM:@{SAMC_UNIQUE_ID:userIds}};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "public-query"
//        "token": "token",
//    },
//    "body":
//    {
//    key: //option
//    location:{
//        "location_info":{
//            “longitude”:
//            “latitude
//        }//option
//        "place_id": " "//option
//        "address": " "//option
//    }     
//    }
//}
+ (NSDictionary *)queryPublicWithKey:(NSString *)key
                            location:(NSDictionary *)location
{
    location = location ?:@{};
    NSDictionary *header = @{SAMC_ACTION:SAMC_PUBLIC_QUERY,SAMC_TOKEN:[SAMCServerAPI token]};
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    if ((key != nil) && [key length] > 0) {
        [body setValue:key forKey:SAMC_KEY];
    }
    [body setValue:location forKey:SAMC_LOCATION];
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "follow-list-query"
//        "token": "token",
//    },
//    "body" :
//    {
//    } 
//}
+ (NSDictionary *)queryFollowList
{
    NSDictionary *header = @{SAMC_ACTION:SAMC_FOLLOW_LIST_QUERY,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "contact-list-query"
//        "token": "token",
//    },
//    "body" :
//    {
//        “type[0,1]”: 0 customer  1 servicer
//    } 
//}
+ (NSDictionary *)queryContactList:(SAMCContactListType)type
{
    NSDictionary *header = @{SAMC_ACTION:SAMC_CONTACT_LIST_QUERY,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_TYPE:@(type)};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "contact "
//        "token": "token",
//    },
//    "body" :
//    {
//        "opt": 0: add  1:remove
//        "type" [0/1]: 0: add into to contact /remove contact
//                      1:add into customer contact/ move from customer to contact
//        "id": unique id in samchat
//    } 
//}
+ (NSDictionary *)addOrRemove:(BOOL)isAdd
                      contact:(NSString *)userId
                         type:(SAMCContactListType)type
{
    NSNumber *uniqueId = @([userId integerValue]);
    NSDictionary *header = @{SAMC_ACTION:SAMC_CONTACT,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:isAdd ? @(0):@(1),
                           SAMC_TYPE:@(type),
                           SAMC_ID:uniqueId};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "send-invite-msg",
//        "token": "token"
//    },
//    "body":
//    {
//        "phones":[{
//            “countrycode”: “”//option
//            “cellphone”:””
//        }]
//        "msg":
//    }
//}
+ (NSDictionary *)sendInviteMsg:(NSArray *)phones
{
    NSDictionary *header = @{SAMC_ACTION:SAMC_SEND_INVITE_MSG,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_PHONES:phones};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "advertisement-write"
//        "token": "token",
//    },
//    "body" :
//    {
//        "type":[0/1] 0: text  1:picture   2:vedio
//        "content": text or url
//    }
//}
+ (NSDictionary *)writeAdvertisementType:(SAMCAdvertisementType)type
                                 content:(NSString *)content
{
    content = content ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_ADVERTISEMENT_WRITE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_TYPE:@(type),SAMC_CONTENT:content};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "avatar-update",
//        "token"  : "token"
//    },
//    "body":
//    {
//        "avatar":
//        {
//            "origin": http://121.42.207.185/avatar/2016/1/18/origin_1453123489091.png
//            “thumb:” http://121.42.207.185/avatar/2016/1/18/thumb_1453123489091.png
//        },
//    }
//}
+ (NSDictionary *)updateAvatar:(NSString *)url
{
    url = url ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_AVATAR_UPDATE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_AVATAR:@{SAMC_ORIGIN:url, SAMC_THUMB:@""}};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

#pragma mark - Token
+ (NSString *)token
{
    NSString *token = [[[NTESLoginManager sharedManager] currentLoginData] finalToken];
    token = token ?:@"";
    return token;
}

@end
