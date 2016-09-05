//
//  SAMCSettingPortraitCell.m
//  SamChat
//
//  Created by HJ on 7/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingPortraitCell.h"
#import "NIMCommonTableData.h"
#import "UIView+NTES.h"
#import "NTESSessionUtil.h"
#import "NIMAvatarImageView.h"

@interface SAMCSettingPortraitCell()

@property (nonatomic,strong) NIMAvatarImageView *avatar;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UILabel *accountLabel;

@property (nonatomic, strong) UIButton *topButton;
@property (nonatomic, strong) UIButton *bottomButton;

@end

@implementation SAMCSettingPortraitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat avatarWidth = 55.f;
//        _avatar = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, avatarWidth, avatarWidth)];
        _avatar = [[NIMAvatarImageView alloc] init];
        _avatar.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_avatar];
        _topButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _topButton.translatesAutoresizingMaskIntoConstraints = NO;
        _topButton.titleEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
        _topButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _topButton.backgroundColor = [UIColor blueColor];
        [self addSubview:_topButton];
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomButton.titleEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
        _bottomButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _bottomButton.backgroundColor = [UIColor blueColor];
        [self addSubview:_bottomButton];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_avatar]-10-[_topButton]-20-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_avatar,_topButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_avatar]-5-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_avatar)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_avatar
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_topButton
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_bottomButton
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_topButton
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_bottomButton
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_topButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_bottomButton
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_topButton]-10-[_bottomButton]-5-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_topButton,_bottomButton)]];
//        _nameLabel      = [[UILabel alloc] initWithFrame:CGRectZero];
//        _nameLabel.font = [UIFont systemFontOfSize:18.f];
//        [self addSubview:_nameLabel];
//        _accountLabel   = [[UILabel alloc] initWithFrame:CGRectZero];
//        _accountLabel.font = [UIFont systemFontOfSize:14.f];
//        _accountLabel.textColor = [UIColor grayColor];
//        [self addSubview:_accountLabel];
    }
    return self;
}

- (void)refreshData:(NIMCommonTableRow *)rowData tableView:(UITableView *)tableView
{
    NSDictionary *extraInfo = rowData.extraInfo;
    
    [self.topButton setTitle:extraInfo[SAMC_CELL_EXTRA_TOP_TEXT_KEY] forState:UIControlStateNormal];
    [self.bottomButton setTitle:extraInfo[SAMC_CELL_EXTRA_BOTTOM_TEXT_KEY] forState:UIControlStateNormal];
    NSString *uid = extraInfo[SAMC_CELL_EXTRA_UID_KEY];
    if ([uid isKindOfClass:[NSString class]]) {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:uid];
        self.nameLabel.text   = info.showName ;
        [self.nameLabel sizeToFit];
        self.accountLabel.text = [NSString stringWithFormat:@"帐号：%@",uid];
        [self.accountLabel sizeToFit];
        [self.avatar nim_setImageWithURL:[NSURL URLWithString:info.avatarUrlString] placeholderImage:info.avatarImage options:NIMWebImageRetryFailed];
    }
    
    [self.topButton removeTarget:tableView.viewController action:NULL forControlEvents:UIControlEventTouchUpInside];
    SEL topAction = NSSelectorFromString(extraInfo[SAMC_CELL_EXTRA_TOP_ACTION_KEY]);
    [self.topButton addTarget:tableView.viewController action:topAction forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomButton removeTarget:tableView.viewController action:NULL forControlEvents:UIControlEventTouchUpInside];
    SEL bottomAction = NSSelectorFromString(extraInfo[SAMC_CELL_EXTRA_BOTTOM_ACTION_KEY]);
    [self.bottomButton addTarget:tableView.viewController action:bottomAction forControlEvents:UIControlEventTouchUpInside];
}


//#define AvatarLeft 30
//#define TitleAndAvatarSpacing 12
//#define TitleTop 22
//#define AccountBottom 22
//
//- (void)layoutSubviews{
//    [super layoutSubviews];
//    self.avatar.left    = AvatarLeft;
//    self.avatar.centerY = self.height * .5f;
//    self.nameLabel.left = self.avatar.right + TitleAndAvatarSpacing;
//    self.nameLabel.top  = TitleTop;
//    self.accountLabel.left    = self.nameLabel.left;
//    self.accountLabel.bottom  = self.height - AccountBottom;
//}

@end
