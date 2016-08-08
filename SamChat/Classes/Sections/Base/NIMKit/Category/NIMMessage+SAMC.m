//
//  NIMMessage+SAMC.m
//  SamChat
//
//  Created by HJ on 8/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMMessage+SAMC.h"
#import "NIMKitUtil.h"
#import "NTESSnapchatAttachment.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESChartletAttachment.h"
#import "NTESWhiteboardAttachment.h"

@implementation NIMMessage (SAMC)

- (NSString *)messageContent
{
    NSString *text = @"";
    switch (self.messageType) {
        case NIMMessageTypeCustom:
            text = [self customMessageContent];
            break;
        case NIMMessageTypeText:
            text = self.text;
            break;
        case NIMMessageTypeAudio:
            text = @"[语音]";
            break;
        case NIMMessageTypeImage:
            text = @"[图片]";
            break;
        case NIMMessageTypeVideo:
            text = @"[视频]";
            break;
        case NIMMessageTypeLocation:
            text = @"[位置]";
            break;
        case NIMMessageTypeNotification:
            return [self notificationMessageContent];
        case NIMMessageTypeFile:
            text = @"[文件]";
            break;
        case NIMMessageTypeTip:
            text = @"[提醒消息]";   //调整成你需要显示的文案
            break;
        default:
            text = @"[未知消息]";
    }
    if (self.session.sessionType == NIMSessionTypeP2P) {
        return text;
    }else{
        NSString *nickName = [NIMKitUtil showNick:self.from inSession:self.session];
        return nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
    }
}

#pragma mark - Private
- (NSString *)customMessageContent
{
    NSString *text = @"";
    NIMCustomObject *object = self.messageObject;
    if ([object.attachment isKindOfClass:[NTESSnapchatAttachment class]]) {
        text = @"[阅后即焚]";
    }
    else if ([object.attachment isKindOfClass:[NTESJanKenPonAttachment class]]) {
        text = @"[猜拳]";
    }
    else if ([object.attachment isKindOfClass:[NTESChartletAttachment class]]) {
        text = @"[贴图]";
    }
    else if ([object.attachment isKindOfClass:[NTESWhiteboardAttachment class]]) {
        text = @"[白板]";
    }else{
        text = @"[未知消息]";
    }
    return text;
}

- (NSString *)notificationMessageContent
{
    NIMNotificationObject *object = self.messageObject;
    if (object.notificationType == NIMNotificationTypeNetCall) {
        NIMNetCallNotificationContent *content = (NIMNetCallNotificationContent *)object.content;
        if (content.callType == NIMNetCallTypeAudio) {
            return @"[网络通话]";
        }
        return @"[视频聊天]";
    }
    if (object.notificationType == NIMNotificationTypeTeam) {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.session.sessionId];
        if (team.type == NIMTeamTypeNormal) {
            return @"[讨论组信息更新]";
        }else{
            return @"[群信息更新]";
        }
    }
    return @"[未知消息]";
}

@end
