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
    return NO;
}

- (BOOL)shouldShowNickName:(NIMMessageModel *)model{
    return NO;
}

- (BOOL)shouldShowLeft:(NIMMessageModel *)model
{
    return !model.message.isOutgoingMsg;
}

- (NSArray *)customViews:(NIMMessageModel *)model
{
    return nil;
}

@end