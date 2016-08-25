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

#define SAMC_API_USER_REGISTER_CODE_REQUEST @"api_1.0_user_registerCodeRequest.do"
#define SAMC_API_USER_SIGNUP_CODE_VERIFY    @"api_1.0_user_signupCodeVerify.do"
#define SAMC_API_USER_REGISTER              @"api_1.0_user_register.do"
#define SAMC_API_USER_LOGIN                 @"api_1.0_user_login.do"
#define SAMC_API_USER_LOGOUT                @"api_1.0_user_logout.do"
#define SAMC_API_USER_CREATE_SAM_PROS       @"api_1.0_user_createSamPros.do"
#define SAMC_API_USER_FIND_PWD_CODE_REQUEST @"api_1.0_user_findpwdCodeRequest.do"
#define SAMC_API_USER_FIND_PWD_CODE_VERIFY  @"api_1.0_user_findpwdCodeVerify.do"
#define SAMC_API_USER_FIND_PWD_UPDATE       @"api_1.0_user_findpwdUpdate.do"
#define SAMC_API_USER_PWD_UPDATE            @"api_1.0_user_pwdUpdate.do"
#define SAMC_API_QUESTION_QUESTION          @"api_1.0_question_question.do"

#define SAMC_URL_REGISTER_CODE_REQUEST      SAMC_API_PREFIX@""SAMC_API_USER_REGISTER_CODE_REQUEST
#define SAMC_URL_SIGNUP_CODE_VERIFY         SAMC_API_PREFIX@""SAMC_API_USER_SIGNUP_CODE_VERIFY
#define SAMC_URL_USER_REGISTER              SAMC_API_PREFIX@""SAMC_API_USER_REGISTER
#define SAMC_URL_USER_LOGIN                 SAMC_API_PREFIX@""SAMC_API_USER_LOGIN
#define SAMC_URL_USER_LOGOUT                SAMC_API_PREFIX@""SAMC_API_USER_LOGOUT
#define SAMC_URL_PROFILE_APP_KEY_GET        SAMC_API_PREFIX@""SAMC_API_PROFILE_APP_KEY_GET
#define SAMC_URL_USER_CREATE_SAM_PROS       SAMC_API_PREFIX@""SAMC_API_USER_CREATE_SAM_PROS
#define SAMC_URL_USER_FIND_PWD_CODE_REQUEST SAMC_API_PREFIX@""SAMC_API_USER_FIND_PWD_CODE_REQUEST
#define SAMC_URL_USER_FIND_PWD_CODE_VERIFY  SAMC_API_PREFIX@""SAMC_API_USER_FIND_PWD_CODE_VERIFY
#define SAMC_URL_USER_FIND_PWD_UPDATE       SAMC_API_PREFIX@""SAMC_API_USER_FIND_PWD_UPDATE
#define SAMC_URL_QUESTION_QUESTION          SAMC_API_PREFIX@""SAMC_API_QUESTION_QUESTION

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

#define SAMC_COUNTRYCODE                @"countrycode"
#define SAMC_CELLPHONE                  @"cellphone"
#define SAMC_DEVICEID                   @"deviceid"
#define SAMC_VERIFYCODE                 @"verifycode"
#define SAMC_USERNAME                   @"username"
#define SAMC_PWD                        @"pwd"
#define SAMC_ACCOUNT                    @"account"
#define SAMC_ID                         @"id"
#define SAMC_OPT                        @"opt"

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

#define SAMC_AVATAR_ORIGIN              @"avatar.origin"
#define SAMC_AVATAR_THUMB               @"avatar.thumb"
#define SAMC_HEADER_CATEGORY            @"header.category"
#define SAMC_USER_ID                    @"user.id"
#define SAMC_USER_USERNAME              @"user.username"

#define SAMC_PUSHCATEGORY_NEWQUESTION   @"1"

#define SAMC_SAM_PROS_INFO_COMPANY_NAME         @"sam_pros_info.company_name"
#define SAMC_SAM_PROS_INFO_SERVICE_CATEGORY     @"sam_pros_info.service_category"
#define SAMC_SAM_PROS_INFO_SERVICE_DESCRIPTION  @"sam_pros_info.service_description"
#define SAMC_SAM_PROS_INFO_COUNTRYCODE          @"sam_pros_info.countrycode"
#define SAMC_SAM_PROS_INFO_PHONE                @"sam_pros_info.phone"
#define SAMC_SAM_PROS_INFO_EMAIL                @"sam_pros_info.email"
#define SAMC_SAM_PROS_INFO_ADDRESS              @"sam_pros_info.address"

#endif /* SAMCServerAPIMacro_h */
