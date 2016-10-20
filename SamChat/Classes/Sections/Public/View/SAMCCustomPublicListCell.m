//
//  SAMCCustomPublicListCell.m
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomPublicListCell.h"
#import "SAMCAvatarImageView.h"
#import "SAMCSession.h"
#import "NIMKitUtil.h"

@interface SAMCCustomPublicListCell ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation SAMCCustomPublicListCell

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
    [self addSubview:self.timeLabel];
    [self addSubview:self.messageLabel];
    
    [_avatarView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_avatarView
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0f
                                                             constant:0.0f]];
    [_avatarView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                             constant:60.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarView]-10-[_nameLabel]-5-[_categoryLabel]-5-[_timeLabel]-16-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_nameLabel,_categoryLabel,_timeLabel)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_categoryLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_timeLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarView]-10-[_messageLabel]-16-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_messageLabel)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:12.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:8.0f]];
    [_nameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_categoryLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_categoryLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setPublicSession:(SAMCPublicSession *)publicSession
{
    self.nameLabel.text = publicSession.spBasicInfo.username;
    self.categoryLabel.text = publicSession.spBasicInfo.spServiceCategory;
    self.timeLabel.text = [NIMKitUtil showTime:publicSession.lastMessageTime showDetail:NO];
    self.messageLabel.text = publicSession.lastMessageContent;
    
    NSURL *url = publicSession.spBasicInfo.avatar? [NSURL URLWithString:publicSession.spBasicInfo.avatar] : nil;
    [self.avatarView samc_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_user"] options:SDWebImageRetryFailed];
    if (publicSession.unreadCount == 0) {
        self.avatarView.circleColor = SAMC_COLOR_LIGHTGREY;
    } else {
        self.avatarView.circleColor = SAMC_COLOR_LIME;
    }
}

#pragma mark - lazy load
- (SAMCAvatarImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[SAMCAvatarImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.userInteractionEnabled = false;
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _nameLabel.textColor = SAMC_COLOR_INK;
    }
    return _nameLabel;
}

- (UILabel *)categoryLabel
{
    if (_categoryLabel == nil) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _categoryLabel.font = [UIFont systemFontOfSize:13.0f];
        _categoryLabel.textColor = SAMC_COLOR_INK;
    }
    return _categoryLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.font = [UIFont systemFontOfSize:13.0f];
        _timeLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UILabel *)messageLabel
{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.font = [UIFont systemFontOfSize:15.0f];
        _messageLabel.numberOfLines = 2;
        _messageLabel.textColor = SAMC_COLOR_INK;
    }
    return _messageLabel;
}

@end
