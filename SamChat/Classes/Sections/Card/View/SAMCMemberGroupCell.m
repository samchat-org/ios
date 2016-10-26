//
//  SAMCMemberGroupCell.m
//  SamChat
//
//  Created by HJ on 10/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMemberGroupCell.h"
#import "UIView+NTES.h"

@implementation SAMCMemberGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setMemberGroupView:(NIMMemberGroupView *)memberGroupView
{
    if (_memberGroupView != nil) {
        [_memberGroupView removeFromSuperview];
    }
    _memberGroupView = memberGroupView;
    [self.contentView addSubview:_memberGroupView];
}

@end
