//
//  NTESSessionMsgHelper.m
//  NIMDemo
//
//  Created by ght on 15-1-28.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionMsgConverter.h"
#import "NTESLocationPoint.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESSnapchatAttachment.h"
#import "NTESChartletAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "SAMCImageAttachment.h"
#import "NSString+SAMC.h"

@implementation NTESSessionMsgConverter


+ (NIMMessage*)msgWithText:(NSString*)text
{
    NIMMessage *textMessage = [[NIMMessage alloc] init];
    textMessage.text        = text;
    return textMessage;
}

+ (NIMMessage*)msgWithImage:(UIImage*)image
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NIMImageObject * imageObject = [[NIMImageObject alloc] initWithImage:image];
    imageObject.displayName = [NSString stringWithFormat:@"图片发送于%@",dateString];
    NIMImageOption *option = [[NIMImageOption alloc] init];
    option.compressQuality = 0.8;
    imageObject.option = option;
    NIMMessage *message          = [[NIMMessage alloc] init];
    message.messageObject        = imageObject;
    message.apnsContent = @"发来了一张图片";
    return message;
}

+ (NIMMessage*)msgWithAudio:(NSString*)filePath
{
    NIMAudioObject *audioObject = [[NIMAudioObject alloc] initWithSourcePath:filePath];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = audioObject;
    message.apnsContent = @"发来了一段语音";
    return message;
}

+ (NIMMessage*)msgWithVideo:(NSString*)filePath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NIMVideoObject *videoObject = [[NIMVideoObject alloc] initWithSourcePath:filePath];
    videoObject.displayName = [NSString stringWithFormat:@"视频发送于%@",dateString];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = videoObject;
    message.apnsContent = @"发来了一段视频";
    return message;
}

+ (NIMMessage*)msgWithLocation:(NTESLocationPoint*)locationPoint{
    NIMLocationObject *locationObject = [[NIMLocationObject alloc] initWithLatitude:locationPoint.coordinate.latitude
                                                                          longitude:locationPoint.coordinate.longitude
                                                                              title:locationPoint.title];
    NIMMessage *message               = [[NIMMessage alloc] init];
    message.messageObject             = locationObject;
    message.apnsContent = @"发来了一条位置信息";
    return message;
}

+ (NIMMessage*)msgWithJenKenPon:(NTESJanKenPonAttachment *)attachment
{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = attachment;
    message.messageObject             = customObject;
    message.apnsContent = @"发来了猜拳信息";
    return message;
}

+ (NIMMessage*)msgWithSnapchatAttachment:(NTESSnapchatAttachment *)attachment
{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = attachment;
    message.messageObject             = customObject;
    message.apnsContent = @"发来了阅后即焚";
    
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.historyEnabled = NO;
    setting.roamingEnabled = NO;
    setting.syncEnabled    = NO;
    message.setting = setting;
    
    return message;
}


+ (NIMMessage*)msgWithFilePath:(NSString*)path{
    NIMFileObject *fileObject = [[NIMFileObject alloc] initWithSourcePath:path];
    NSString *displayName     = path.lastPathComponent;
    fileObject.displayName    = displayName;
    NIMMessage *message       = [[NIMMessage alloc] init];
    message.messageObject     = fileObject;
    message.apnsContent = @"发来了一个文件";
    return message;
}

+ (NIMMessage*)msgWithFileData:(NSData*)data extension:(NSString*)extension{
    NIMFileObject *fileObject = [[NIMFileObject alloc] initWithData:data extension:extension];
    NSString *displayName;
    if (extension.length) {
        displayName     = [NSString stringWithFormat:@"%@.%@",[NSUUID UUID].UUIDString.samc_MD5String,extension];
    }else{
        displayName     = [NSString stringWithFormat:@"%@",[NSUUID UUID].UUIDString.samc_MD5String];
    }
    fileObject.displayName    = displayName;
    NIMMessage *message       = [[NIMMessage alloc] init];
    message.messageObject     = fileObject;
    message.apnsContent = @"发来了一个文件";
    return message;
}


+ (NIMMessage*)msgWithChartletAttachment:(NTESChartletAttachment *)attachment{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = attachment;
    message.messageObject             = customObject;
    message.apnsContent = @"[贴图]";
    return message;
}

+ (NIMMessage*)msgWithWhiteboardAttachment:(NTESWhiteboardAttachment *)attachment
{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = attachment;
    message.messageObject             = customObject;
    
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.apnsEnabled        = NO;
    message.setting            = setting;

    return message;
}


+ (NIMMessage *)msgWithTip:(NSString *)tip
{
    NIMMessage *message        = [[NIMMessage alloc] init];
    NIMTipObject *tipObject    = [[NIMTipObject alloc] init];
    message.messageObject      = tipObject;
    message.text               = tip;
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.apnsEnabled        = NO;
    message.setting            = setting;
    return message;
}

+ (NIMMessage *)createForwardMsgWithMsg:(NIMMessage *)message
{
    NIMMessage *forwardMessage;
    if (message.messageType == NIMMessageTypeText) {
        forwardMessage = [NTESSessionMsgConverter msgWithText:message.text];
    } else if (message.messageType == NIMMessageTypeImage) {
        NIMImageObject *imageObject = message.messageObject;
        UIImage *image;
        if([[NSFileManager defaultManager] fileExistsAtPath:imageObject.path]){
            image = [UIImage imageWithContentsOfFile:imageObject.path];
        } else {
            image = [UIImage imageWithContentsOfFile:imageObject.thumbPath];
        }
        forwardMessage = [NTESSessionMsgConverter msgWithImage:image];
    } else if (message.messageType == NIMMessageTypeAudio) {
        NIMAudioObject *audioObject = message.messageObject;
        forwardMessage = [NTESSessionMsgConverter msgWithAudio:audioObject.path];
    } else if (message.messageType == NIMMessageTypeVideo) {
        NIMVideoObject *videoObject = message.messageObject;
        forwardMessage = [NTESSessionMsgConverter msgWithVideo:videoObject.path];
    } else if (message.messageType == NIMMessageTypeCustom) {
        id<NIMMessageObject> messageobject = message.messageObject;
        if ([messageobject isKindOfClass:[NIMCustomObject class]] &&
            [((NIMCustomObject *)messageobject).attachment isKindOfClass:[SAMCImageAttachment class]]) {
            SAMCImageAttachment *imageAttach = (SAMCImageAttachment *)((NIMCustomObject *)messageobject).attachment;
            UIImage *image;
            if([[NSFileManager defaultManager] fileExistsAtPath:imageAttach.path]){
                image = [UIImage imageWithContentsOfFile:imageAttach.path];
            } else {
                image = [UIImage imageWithContentsOfFile:imageAttach.thumbPath];
            }
            forwardMessage = [NTESSessionMsgConverter msgWithImage:image];
        } else {
            forwardMessage = [[NIMMessage alloc] init];
            forwardMessage.messageObject = message.messageObject;
        }
    } else {
        DDLogError(@"unknow message createForwardMsgWithMsg:%@", message);
        forwardMessage = [[NIMMessage alloc] init];
        forwardMessage.messageObject = message.messageObject;
    }
    message.apnsContent = message.apnsContent;
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:message.remoteExt];
    [ext removeObjectForKey:MESSAGE_EXT_QUESTION_ID_KEY];
    [ext removeObjectForKey:MESSAGE_EXT_PUBLIC_ID_KEY];
    message.remoteExt = ext;
    return forwardMessage;
}

@end
