//
//  SAMCServerAPIMacro.h
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#ifndef SAMCServerAPIMacro_h
#define SAMCServerAPIMacro_h

#define SAMC_API_PREFIX                 @"http://ec2-54-222-170-218.cn-north-1.compute.amazonaws.com.cn:8081/sam_svr/"

#define SAMC_URL_REGISTER_CODE_REQUEST      SAMC_API_PREFIX@"api_1.0_user_registerCodeRequest.do"
#define SAMC_URL_SIGNUP_CODE_VERIFY         SAMC_API_PREFIX@"api_1.0_user_signupCodeVerify.do"
#define SAMC_URL_USER_REGISTER              SAMC_API_PREFIX@"api_1.0_user_register.do"
#define SAMC_URL_USER_LOGIN                 SAMC_API_PREFIX@"api_1.0_user_login.do"
#define SAMC_URL_USER_LOGOUT                SAMC_API_PREFIX@"api_1.0_user_logout.do"
#define SAMC_URL_USER_CREATE_SAM_PROS       SAMC_API_PREFIX@"api_1.0_user_createSamPros.do"
#define SAMC_URL_USER_FIND_PWD_CODE_REQUEST SAMC_API_PREFIX@"api_1.0_user_findpwdCodeRequest.do"
#define SAMC_URL_USER_FIND_PWD_CODE_VERIFY  SAMC_API_PREFIX@"api_1.0_user_findpwdCodeVerify.do"
#define SAMC_URL_USER_FIND_PWD_UPDATE       SAMC_API_PREFIX@"api_1.0_user_findpwdUpdate.do"
#define SAMC_URL_USER_QUERYFUZZY            SAMC_API_PREFIX@"api_1.0_user_queryFuzzy.do"
#define SAMC_URL_QUESTION_QUESTION          SAMC_API_PREFIX@"api_1.0_question_question.do"
#define SAMC_URL_OFFICIALACCOUNT_FOLLOW             SAMC_API_PREFIX@"api_1.0_officialAccount_follow.do"
#define SAMC_URL_OFFICIALACCOUNT_FOLLOW_LIST_QUERY  SAMC_API_PREFIX@"api_1.0_officialAccount_followListQuery.do"
#define SAMC_URL_OFFICIALACCOUNT_PUBLIC_QUERY       SAMC_API_PREFIX@"api_1.0_officialAccount_publicQuery.do"
#define SAMC_URL_COMMON_SEND_INVITE_MSG             SAMC_API_PREFIX@"api_1.0_common_sendInviteMsg.do"
#define SAMC_URL_ADVERTISEMENT_ADVERTISEMENT_WRITE  SAMC_API_PREFIX@"api_1.0_advertisement_advertisementWrite.do"

#define SAMC_HEADER                     @"header"
#define SAMC_BODY                       @"body"

#define SAMC_RET                        @"ret"
#define SAMC_TOKEN                      @"token"
#define SAMC_USER                       @"user"

#define SAMC_ACTION                     @"action"

#define SAMC_REGISTER_CODE_REQUEST      @"register-code-request"
#define SAMC_SIGNUP_CODE_VERIFY         @"signup-code-verify"
#define SAMC_REGISTER                   @"register"
#define SAMC_LOGIN                      @"login"
#define SAMC_LOGOUT                     @"logout"
#define SAMC_APPKEY_GET                 @"appkey-get"
#define SAMC_CREATE_SAM_PROS            @"create-sam-pros"
#define SAMC_FINDPWD_CODE_REQUEST       @"findpwd-code-request"
#define SAMC_FINDPWD_CODE_VERIFY        @"findpwd-code-verify"
#define SAMC_FINDPWD_UPDATE             @"findpwd-update"
#define SAMC_QUESTION                   @"question"
#define SAMC_FOLLOW                     @"follow"
#define SAMC_QUERY                      @"query"
#define SAMC_QUERY_FUZZY                @"query-fuzzy"
#define SAMC_PUBLIC_QUERY               @"public-query"
#define SAMC_FOLLOW_LIST_QUERY          @"follow-list-query"
#define SAMC_SEND_INVITE_MSG            @"send-invite-msg"
#define SAMC_ADVERTISEMENT_WRITE        @"advertisement-write"

#define SAMC_COUNTRYCODE                @"countrycode"
#define SAMC_CELLPHONE                  @"cellphone"
#define SAMC_DEVICEID                   @"deviceid"
#define SAMC_VERIFYCODE                 @"verifycode"
#define SAMC_USERNAME                   @"username"
#define SAMC_PWD                        @"pwd"
#define SAMC_ACCOUNT                    @"account"
#define SAMC_ID                         @"id"
#define SAMC_OPT                        @"opt"
#define SAMC_PARAM                      @"param"
#define SAMC_SEARCH_KEY                 @"search_key"
#define SAMC_KEY                        @"key"

#define SAMC_COMPANY_NAME               @"company_name"
#define SAMC_SERVICE_CATEGORY           @"service_category"
#define SAMC_SERVICE_DESCRIPTION        @"service_description"
#define SAMC_PHONE                      @"phone"
#define SAMC_EMAIL                      @"email"
#define SAMC_LOCATION                   @"location"
#define SAMC_LOCATION_INFO              @"location_info"
#define SAMC_LONGITUDE                  @"longitude"
#define SAMC_LATITUDE                   @"latitude"
#define SAMC_PLACE_ID                   @"place_id"
#define SAMC_ADDRESS                    @"address"
#define SAMC_TYPE                       @"type"
#define SAMC_LASTUPDATE                 @"lastupdate"
#define SAMC_QUESTION_ID                @"question_id"
#define SAMC_DATETIME                   @"datetime"
#define SAMC_USERS                      @"users"
#define SAMC_BLOCK_TAG                  @"block_tag"
#define SAMC_FAVOURITE_TAG              @"favourite_tag"
#define SAMC_SAM_PROS_INFO              @"sam_pros_info"
#define SAMC_PHONES                     @"phones"
#define SAMC_CONTENT                    @"content"
#define SAMC_ADV_ID                     @"adv_id"
#define SAMC_PUBLISH_TIMESTAMP          @"publish_timestamp"

#define SAMC_AVATAR_ORIGIN              @"avatar.origin"
#define SAMC_AVATAR_THUMB               @"avatar.thumb"
#define SAMC_HEADER_CATEGORY            @"header.category"
#define SAMC_USER_ID                    @"user.id"
#define SAMC_USER_USERNAME              @"user.username"
#define SAMC_LOCATION_ADDRESS           @"location.address"
#define SAMC_BODY_DEST_ID               @"body.dest_id"

#define SAMC_PUSHCATEGORY_NEWQUESTION   @"1"

#define SAMC_SAM_PROS_INFO_COMPANY_NAME         @"sam_pros_info.company_name"
#define SAMC_SAM_PROS_INFO_SERVICE_CATEGORY     @"sam_pros_info.service_category"
#define SAMC_SAM_PROS_INFO_SERVICE_DESCRIPTION  @"sam_pros_info.service_description"
#define SAMC_SAM_PROS_INFO_COUNTRYCODE          @"sam_pros_info.countrycode"
#define SAMC_SAM_PROS_INFO_PHONE                @"sam_pros_info.phone"
#define SAMC_SAM_PROS_INFO_EMAIL                @"sam_pros_info.email"
#define SAMC_SAM_PROS_INFO_ADDRESS              @"sam_pros_info.address"

#endif /* SAMCServerAPIMacro_h */
