//
//  SAMCPublicCustomMsgCellLayoutConfig.m
//  SamChat
//
//  Created by HJ on 9/12/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicCustomMsgCellLayoutConfig.h"

@implementation SAMCPublicCustomMsgCellLayoutConfig

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

- (UIEdgeInsets)cellInsets:(NIMMessageModel *)model
{
    CGFloat cellTopToBubbleTop           = 3;
    CGFloat otherNickNameHeight          = 20;
    CGFloat otherBubbleOriginX           = [self shouldShowAvatar:model]? 55 : 0;
    CGFloat cellBubbleButtomToCellButtom = 13;
    if ([self shouldShowNickName:model])
    {
        //要显示名字
        return UIEdgeInsetsMake(cellTopToBubbleTop + otherNickNameHeight ,otherBubbleOriginX,cellBubbleButtomToCellButtom, 0);
    }
    else
    {
        return UIEdgeInsetsMake(cellTopToBubbleTop,otherBubbleOriginX,cellBubbleButtomToCellButtom, 0);
    }
    
}

@end
