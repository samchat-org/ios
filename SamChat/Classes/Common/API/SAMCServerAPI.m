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
                           SAMC_DEVICEID:deviceId,
                           SAMC_DEVICE_TYPE:[SAMCDeviceUtil deviceInfo],
                           SAMC_APP_VERSION:[SAMCDeviceUtil appInfo]};
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
                           SAMC_DEVICEID:deviceId,
                           SAMC_DEVICE_TYPE:[SAMCDeviceUtil deviceInfo],
                           SAMC_APP_VERSION:[SAMCDeviceUtil appInfo]};
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
//        "action" : " pwd-update",
//        "token"	: “”
//    },
//    "body":
//    {
//        "old_pwd"	: “”
//        "new_pwd"	: “”
//    }
//}
+ (NSDictionary *)updatePWDFrom:(NSString *)currentPWD
                             to:(NSString *)changePWD
{
    currentPWD = currentPWD ?:@"";
    changePWD = changePWD ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_PWD_UPDATE, SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OLD_PWD:currentPWD, SAMC_NEW_PWD:changePWD};
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
//        "action" : "query-popular-request"
//        "token": "token"
//    },
//    "body" :
//    {
//        “count”:50
//    } 
//}
+ (NSDictionary *)queryPopularRequest:(NSInteger)count
{
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUERY_POPULAR_REQUEST,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_COUNT:@(count)};
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
//        "action" : "block",
//        "token"  : "token"
//    },
//    "body":
//    {
//        "opt" :  [0/1]
//        0 :  unblock
//        1 :  block
//        " id " : unique_id_in_samchat of Sam-pros
//    }
//}
+ (NSDictionary *)block:(BOOL)blockFlag
                   user:(NSString *)userId
{
    NSNumber *uniqueId = @([userId integerValue]);
    NSDictionary *header = @{SAMC_ACTION:SAMC_BLOCK,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:blockFlag? @(1):@(0),
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
+ (NSDictionary *)queryAccurateUser:(id)key type:(SAMCQueryAccurateUserType)type
{
    key = key ? :@"";
    NSString *typeKey;
    if (type == SAMCQueryAccurateUserTypeCellPhone) {
        typeKey = SAMC_CELLPHONE;
    } else if (type == SAMCQueryAccurateUserTypeUniqueId) {
        typeKey = SAMC_UNIQUE_ID;
    } else {
        typeKey = SAMC_USERNAME;
    }
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUERY_ACCURATE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_OPT:@(2),
                           SAMC_PARAM:@{SAMC_TYPE:@(type),typeKey:key}};
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
//        "action" : "query-without-token"
//    },
//    "body":
//    {
//        "opt":4,   4: User Query Without Token
//        "param":
//        {
//            "type":[0/1/2] 0: cellphone 2:username
//            "username":"" //optional
//            "countrycode":"" //optional
//            "cellphone ":"" //optional
//        }
//    }
//}
+ (NSDictionary *)queryWithoutToken:(NSString *)username
{
    username = username ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUERY_WITHOUT_TOKEN};
    NSDictionary *body = @{SAMC_OPT:@(4),
                           SAMC_PARAM:@{SAMC_TYPE:@(2),SAMC_USERNAME:username}};
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
//    count:
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
                        currentCount:(NSInteger)count
                            location:(NSDictionary *)location
{
    location = location ?:@{};
    NSDictionary *header = @{SAMC_ACTION:SAMC_PUBLIC_QUERY,SAMC_TOKEN:[SAMCServerAPI token]};
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    if ([key length] > 0) {
        [body setValue:key forKey:SAMC_KEY];
    }
    [body setValue:@(count) forKey:SAMC_COUNT];
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
//        "content_thumb":  //option  url,
//        ”message_id”: “DASDADNAB12123”
//    }
//}
+ (NSDictionary *)writeAdvertisementType:(SAMCAdvertisementType)type
                                 content:(NSString *)content
                               messageId:(NSString *)messageId
{
    content = content ?:@"";
    messageId = messageId ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_ADVERTISEMENT_WRITE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_TYPE:@(type),
                           SAMC_CONTENT:content,
                           SAMC_MESSAGE_ID:messageId};
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

//{
//    "header":
//    {
//        "action" : "get-places-info-request",
//        "token"  : "token"
//    },
//    "body":
//    {
//        "key" :
//    }
//}
+ (NSDictionary *)getPlacesInfo:(NSString *)key
{
    key = key ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_GET_PLACES_INFO_REQUEST,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_KEY:key};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "query-state-date"
//        "token": "token",
//    },
//    "body" :
//    {
//        
//    } 
//}
+ (NSDictionary *)queryStateDate
{
    NSDictionary *header = @{SAMC_ACTION:SAMC_QUERY_STATE_DATE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "profile-update",
//        "token"  : "token"
//    },
//    "body":
//    {
//        "user":{
//            “countrycode”://option
//            “cellphone”: //option
//            “email”: //option
//            “address”:// option
//            “sam_pros_info”:{
//                “company_name”:”KFC”
//                “service_category”:“fast food”
//                “service_description”:”deliver all kinds of fast food”
//                “countrycode”: // option
//                “phone”: // option
//                “email”: // option
//                “address”: // option
//            }
//        }
//    }
//}
+ (NSDictionary *)updateProfile:(NSDictionary *)profile
{
    profile = profile ?:@{};
    NSDictionary *header = @{SAMC_ACTION:SAMC_PROFILE_UPDATE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_USER:profile};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "editCellPhone-code-request",
//        "token"  : "token"
//    },
//    "body":
//    {
//        "countrycode" : “”
//        "cellphone"	: “”
//    }
//}
+ (NSDictionary *)editCellPhoneCodeRequestWithCountryCode:(NSString *)countryCode
                                                cellPhone:(NSString *)cellPhone
{
    countryCode = countryCode ?:@"";
    cellPhone = cellPhone ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_EDITCELLPHONE_CODE_REQUEST,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,SAMC_CELLPHONE:cellPhone};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "editCellPhone-update",
//        "token"  : "token"
//    },
//    "body":
//    {
//        "countrycode" :
//        "cellphone"	: “”
//        "verifycode"  :
//    }
//}
+ (NSDictionary *)editCellPhoneUpdateWithCountryCode:(NSString *)countryCode
                                           cellPhone:(NSString *)cellPhone
                                          verifyCode:(NSString *)verifyCode
{
    countryCode = countryCode ?:@"";
    cellPhone = cellPhone ?:@"";
    verifyCode = verifyCode ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_EDITCELLPHONE_UPDATE,SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_COUNTRYCODE:countryCode,
                           SAMC_CELLPHONE:cellPhone,
                           SAMC_VERIFYCODE:verifyCode};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "update-question-notify"
//        "token": "token"
//    },
//    "body" :
//    {
//        “question_notify”:0  //   1. need notify   0. no
//    } 
//}
+ (NSDictionary *)updateQuestionNotify:(BOOL)needNotify
{
    NSDictionary *header = @{SAMC_ACTION:SAMC_UPDATE_QUESTION_NOTIFY, SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_QUESTION_NOTIFY:needNotify ? @(1) : @(0)};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "create-samchat-id"
//        "token": "token"
//    },
//    "body" :
//    {
//        “samchat_id”:”123123132” //
//    } 
//}
+ (NSDictionary *)createSamchatId:(NSString *)samchatId
{
    samchatId = samchatId ?:@"";
    NSDictionary *header = @{SAMC_ACTION:SAMC_CREATE_SAMCHAT_ID, SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_SAMCHAT_ID:samchatId};
    return @{SAMC_HEADER:header,SAMC_BODY:body};
}

//{
//    "header":
//    {
//        "action" : "recall"
//        "token": "token"
//    },
//    "body" :
//    {
//        “type”:1  // 1 question  2 advertisement
//        “business_id”:123123123  // question_id , ads_id
//    } 
//}
+ (NSDictionary *)recallType:(SAMCRecallType)type
                  businessId:(NSInteger)businessId
                   timestamp:(NSTimeInterval)timestamp
{
    NSDictionary *header = @{SAMC_ACTION:SAMC_RECALL, SAMC_TOKEN:[SAMCServerAPI token]};
    NSDictionary *body = @{SAMC_TYPE:@(type),
                           SAMC_BUSINESS_ID:@(businessId),
                           SAMC_PUBLISH_TIMESTAMP:@(timestamp)};
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
