//
//  SAMCServerErrorHelper.h
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SAMCServerErrorCode) {
    SAMCServerErrorParseFailed = -1, // 解析失败
    SAMCServerErrorActionUnsupported = -2, // Action参数不支持
    SAMCServerErrorParameterInvalid = -3, // 参数不满足
    SAMCServerErrorTokenFormatWrong = -4, // token格式不正确
    SAMCServerErrorInternalError = -103, // 内部错误
    SAMCServerErrorCellphoneRegistered = -201, // 电话号码已经注册过
    SAMCServerErrorCellphoneInvalid = -202, // 非法电话号码
    SAMCServerErrorPasswordWrong = -203, // 密码错误
    SAMCServerErrorCellphoneUnregistered = -204, // 电话号码未注册
    SAMCServerErrorVerificationCodeWrong = -205, // 验证码错误
    SAMCServerErrorVerCodeGetTooOften = -206, // 申请验证码过于频繁
    SAMCServerErrorUserNotExists = -207, // 此用户不存在
    SAMCServerErrorPasswordAttempsTooOften = -208, // 错误密码尝试过于频繁
    SAMCServerErrorQueryTooOften = -209, // 查询过于频繁
    SAMCServerErrorSendInvitationTooOften = -210, // 发送邀请过于频繁
    SAMCServerErrorVerCodeExpires = -211, // 验证码过期
    SAMCServerErrorTokenInvalid = -401, // token不合法
    SAMCServerErrorAlreadyBeenSP = -501, // 用户已经有Sam-pros Account
    SAMCServerErrorOldPasswordWrong = -502, // 原始密码错误
    SAMCServerErrorNotSP = -503, // 对方非商家用户
    SAMCServerErrorAdvertisementNotFound = -504, // 广告不存在
    SAMCServerErrorWaitforVerification = -505, // 等待商家后台审核
    SAMCServerErrorFollowListLimit = -506, // 关注人数超过最大值
    SAMCServerErrorUnfollowed = -507, // 还未关注此商家
    SAMCServerErrorContactNotAdded = -508, // 还未添加此联系人
    SAMCServerErrorQuestionTooOften = -509, // 发送问题过于频繁
    SAMCServerErrorIamNotSP = -510, // 自己不是商家用户
    
    SAMCServerErrorNetworkUnavailable = 1,
    SAMCServerErrorServerNotReachable = 2,
    SAMCServerErrorUnknowError = 3,
    SAMCServerErrorNetEaseLoginFailed = 4,
};

#define SAMC_SERVER_ERROR_DOMAIN    @"com.github.gknows.samchat"

@interface SAMCServerErrorHelper : NSObject

+ (NSError *)errorWithCode:(SAMCServerErrorCode)code;

@end
