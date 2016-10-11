//
//  SAMCPublicSearchResultCell.m
//  SamChat
//
//  Created by HJ on 10/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSearchResultCell.h"
#import "SAMCAvatarImageView.h"

@interface SAMCPublicSearchResultCell ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation SAMCPublicSearchResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.avatarView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.categoryLabel];
    [self addSubview:self.followButton];
    
    [_avatarView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_avatarView
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0f
                                                             constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarView]-20-[_nameLabel]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_nameLabel)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_categoryLabel
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_avatarView]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_followButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_followButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0f
                                                      constant:-10.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_categoryLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)setUser:(SAMCUser *)user
{
    _user = user;
    _nameLabel.text = user.userInfo.username;
    _categoryLabel.text = user.userInfo.spInfo.serviceCategory;
    
    NSURL *url = user.userInfo.avatar ? [NSURL URLWithString:user.userInfo.avatar] : nil;
    [_avatarView samc_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_user"] options:SDWebImageRetryFailed];
}

- (void)setIsFollowed:(BOOL)isFollowed
{
    _isFollowed = isFollowed;
    [_followButton setTitle:isFollowed?@"Unfollow":@"Follow" forState:UIControlStateNormal];
    [_followButton setTitleColor:isFollowed?UIColorFromRGB(0xA2AEBC):UIColorFromRGB(0x2676B6) forState:UIControlStateNormal];
//    [_followButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
}

#pragma mark - Action
- (void)onOperate:(id)sender
{
    self.followButton.enabled = false;
    __weak typeof(self) wself = self;
    [self.delegate follow:!_isFollowed user:_user completion:^(BOOL success) {
        if (success) {
            self.isFollowed = !_isFollowed;
        }
        wself.followButton.enabled = YES;
    }];
}

#pragma mark - lazy load
- (SAMCAvatarImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[SAMCAvatarImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.circleColor = UIColorFromRGB(0xD8DCE2);
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _nameLabel.textColor = UIColorFromRGB(0x13243F);
    }
    return _nameLabel;
}

- (UILabel *)categoryLabel
{
    if (_categoryLabel == nil) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _categoryLabel.font = [UIFont systemFontOfSize:15.0f];
        _categoryLabel.textColor = UIColorFromRGB(0x4F606D);
    }
    return _categoryLabel;
}

- (UIButton *)followButton
{
    if (_followButton == nil) {
        _followButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _followButton.translatesAutoresizingMaskIntoConstraints = NO;
        _followButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_followButton addTarget:self action:@selector(onOperate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

@end
