//
//  NIMSessionListCell+SAMC.m
//  NIMKit
//
//  Created by HJ on 8/7/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import "NIMSessionListCell+SAMC.h"
#import "UIView+NIM.h"
#import "NIMBadgeView.h"

@implementation NIMSessionListCell (SAMC)

#define NameLabelMaxWidth    160.f
#define MessageLabelMaxWidth 200.f
- (void)refreshBadge:(NSInteger)count
{
    self.nameLabel.nim_width = self.nameLabel.nim_width > NameLabelMaxWidth ? NameLabelMaxWidth : self.nameLabel.nim_width;
    self.messageLabel.nim_width = self.messageLabel.nim_width > MessageLabelMaxWidth ? MessageLabelMaxWidth : self.messageLabel.nim_width;
    if (count) {
        self.badgeView.hidden = NO;
        self.badgeView.badgeValue = @(count).stringValue;
    }else{
        self.badgeView.hidden = YES;
    }
}

@end
