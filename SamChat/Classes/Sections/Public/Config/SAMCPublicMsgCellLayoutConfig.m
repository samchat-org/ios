//
//  SAMCPublicMsgCellLayoutConfig.m
//  SamChat
//
//  Created by HJ on 9/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMsgCellLayoutConfig.h"

@implementation SAMCPublicMsgCellLayoutConfig

- (BOOL)shouldShowAvatar:(NIMMessageModel *)model
{
    return YES;
}

- (BOOL)shouldShowNickName:(NIMMessageModel *)model{
    return NO;
}

- (BOOL)shouldShowLeft:(NIMMessageModel *)model
{
    return !model.message.isOutgoingMsg;
}

- (CGFloat)avatarMargin:(NIMMessageModel *)model
{
    return 8.0f;
}

- (CGFloat)nickNameMargin:(NIMMessageModel *)model
{
    return 0.f;
}

- (NSArray *)customViews:(NIMMessageModel *)model
{
    return nil;
}

@end