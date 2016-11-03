//
//  SAMCBadgeRightCell.m
//  SamChat
//
//  Created by HJ on 11/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCBadgeRightCell.h"
#import "NIMBadgeView.h"
#import "UIView+NIM.h"

@interface SAMCBadgeRightCell ()

@property (nonatomic,strong) NIMBadgeView *badgeView;

@end

@implementation SAMCBadgeRightCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _badgeView = [NIMBadgeView viewWithBadgeTip:@""];
        [self addSubview:_badgeView];
    }
    return self;
}

- (void)refreshBadge:(NSInteger)badge
{
    if (badge) {
        self.badgeView.hidden = NO;
        self.badgeView.badgeValue = @(badge).stringValue;
    }else{
        self.badgeView.hidden = YES;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _badgeView.nim_right   = self.nim_width - 35;
    _badgeView.nim_centerY = self.nim_height * .5f;
}

@end
