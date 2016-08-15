//
//  SAMCServerErrorHelper.m
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServerErrorHelper.h"

@implementation SAMCServerErrorHelper

+ (NSError *)errorWithCode:(SAMCServerErrorCode)code
{
    NSString *localizedDescription = @"";
    switch (code) {
        case SAMCServerErrorParseFailed: // 解析失败
            localizedDescription = @"解析失败";
            break;
        case SAMCServerErrorActionUnsupported: // Action参数不支持
            localizedDescription = @"Action参数不支持";
            break;
        case SAMCServerErrorParameterInvalid: // 参数不满足
            localizedDescription = @"参数不满足";
            break;
        case SAMCServerErrorTokenFormatWrong: // token格式不正确
            localizedDescription = @"token格式不正确";
            break;
        case SAMCServerErrorInternalError: // 内部错误
            localizedDescription = @"内部错误";
            break;
        case SAMCServerErrorCellphoneRegistered: // 电话号码已经注册过
            localizedDescription = @"电话号码已经注册过";
            break;
        case SAMCServerErrorCellphoneInvalid: // 非法电话号码
            localizedDescription = @"非法电话号码";
            break;
        case SAMCServerErrorPasswordWrong: // 密码错误
            localizedDescription = @"密码错误";
            break;
        case SAMCServerErrorCellphoneUnregistered: // 电话号码未注册
            localizedDescription = @"电话号码未注册";
            break;
        case SAMCServerErrorVerificationCodeWrong: // 验证码错误
            localizedDescription = @"验证码错误";
            break;
        case SAMCServerErrorVerCodeGetTooOften: // 申请验证码过于频繁
            localizedDescription = @"申请验证码过于频繁";
            break;
        case SAMCServerErrorUserNotExists: // 此用户不存在
            localizedDescription = @"此用户不存在";
            break;
        case SAMCServerErrorPasswordAttempsTooOften: // 错误密码尝试过于频繁
            localizedDescription = @"错误密码尝试过于频繁";
            break;
        case SAMCServerErrorVerCodeExpires: // 验证码过期
            localizedDescription = @"验证码过期";
            break;
        case SAMCServerErrorQueryTooOften: // 查询过于频繁
            localizedDescription = @"查询过于频繁";
            break;
        case SAMCServerErrorSendInvitationTooOften: // 发送邀请过于频繁
            localizedDescription = @"发送邀请过于频繁";
            break;
        case SAMCServerErrorTokenInvalid: // token不合法
            localizedDescription = @"token不合法";
            break;
        case SAMCServerErrorAlreadyBeenSP: // 用户已经有Sam-pros Account
            localizedDescription = @"用户已经有Sam-pros Account";
            break;
        case SAMCServerErrorOldPasswordWrong: // 原始密码错误
            localizedDescription = @"原始密码错误";
            break;
        case SAMCServerErrorNotSP: // 非商家用户
            localizedDescription = @"非商家用户";
            break;
        case SAMCServerErrorAdvertisementNotFound: // 广告不存在
            localizedDescription = @"广告不存在";
            break;
        case SAMCServerErrorWaitforVerification: // 等待商家后台审核
            localizedDescription = @"等待商家后台审核";
            break;
        case SAMCServerErrorFollowListLimit: // 关注人数超过最大值
            localizedDescription = @"关注人数超过最大值";
            break;
        case SAMCServerErrorUnfollowed: // 还未关注此商家
            localizedDescription = @"还未关注此商家";
            break;
        case SAMCServerErrorContactNotAdded: // 还未添加此联系人
            localizedDescription = @"还未添加此联系人";
            break;
        default:
            break;
    }
    DDLogError(@"SAMC_SERVER_ERROR: %ld, %@", code,localizedDescription);
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:localizedDescription};
    return [NSError errorWithDomain:SAMC_SERVER_ERROR_DOMAIN code:code userInfo:userInfo];
}

@end
