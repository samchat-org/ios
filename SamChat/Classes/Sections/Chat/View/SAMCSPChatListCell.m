//
//  SAMCSPChatListCell.m
//  SamChat
//
//  Created by HJ on 11/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPChatListCell.h"
#import "SAMCAvatarImageView.h"
#import "SAMCSession.h"
#import "NIMKitUtil.h"
#import "NIMBadgeView.h"
#import "UIView+NIM.h"

@interface SAMCSPChatListCell ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NIMBadgeView *badgeView;
@property (nonatomic, strong) UIImageView *muteImageView;

@end

@implementation SAMCSPChatListCell

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
    [self addSubview:self.timeLabel];
    [self addSubview:self.messageLabel];
    [self addSubview:self.badgeView];
    [self addSubview:self.muteImageView];
    
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
                                                             constant:40.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_avatarView]-10-[_nameLabel]-5-[_timeLabel]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_nameLabel,_timeLabel)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_timeLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarView]-10-[_messageLabel]-5-[_muteImageView]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_messageLabel,_muteImageView)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:15.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:-15.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_muteImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_messageLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [_nameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_messageLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_muteImageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_muteImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _badgeView.nim_right = _avatarView.nim_right + 6.0f;
    _badgeView.nim_top = _avatarView.nim_top - 6.0f;
}

- (void)setRecentSession:(SAMCRecentSession *)recentSession
{
    self.messageLabel.text = [recentSession.lastMessageContent length] ? recentSession.lastMessageContent : @" ";
    self.timeLabel.text = [self timestampDescriptionForRecentSession:recentSession];
    
    NIMKitInfo *info = nil;
    if (recentSession.session.sessionType == NIMSessionTypeTeam)
    {
        info = [[NIMKit sharedKit] infoByTeam:recentSession.session.sessionId];
    }
    else
    {
        info = [[NIMKit sharedKit] infoByUser:recentSession.session.sessionId
                                    inSession:recentSession.session.nimSession];
    }
    
    NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
    [self.avatarView samc_setImageWithURL:url placeholderImage:info.avatarImage options:SDWebImageRetryFailed];
    
    if (recentSession.unreadCount) {
        self.badgeView.hidden = NO;
        self.badgeView.badgeValue = [@(recentSession.unreadCount) stringValue];
    } else {
        self.badgeView.hidden = YES;
        self.badgeView.badgeValue = @"";
    }
    
    NSString *name = @"";
    if ([recentSession.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        name = @"Me";
    }
    if (recentSession.session.sessionType == NIMSessionTypeP2P) {
        name = info.showName;
    }else{
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recentSession.session.sessionId];
        name = team.teamName;
    }
    self.nameLabel.text = [name length] ? name : @" ";
    
    BOOL needNotify;
    if (recentSession.session.sessionType == NIMSessionTypeP2P) {
        needNotify = [[NIMSDK sharedSDK].userManager notifyForNewMsg:recentSession.session.sessionId];
    } else {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recentSession.session.sessionId];
        needNotify = [team notifyForNewMsg];
    }
    self.muteImageView.hidden = needNotify;
    self.muteImageView.image = needNotify?nil:[UIImage imageNamed:@"ico_chat_mute"];
}

- (NSString *)nameForRecentSession:(SAMCRecentSession *)recent
{
    if ([recent.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        return @"我的电脑";
    }
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NIMSession *session = [NIMSession session:recent.session.sessionId type:recent.session.sessionType];
        return [NIMKitUtil showNick:recent.session.sessionId inSession:session];
    }else{
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:recent.session.sessionId];
        return team.teamName;
    }
}

- (NSString *)timestampDescriptionForRecentSession:(SAMCRecentSession *)recent
{
    return [NIMKitUtil showTime:recent.lastMessageTime showDetail:NO];
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

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
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
        _messageLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
    }
    return _messageLabel;
}

- (NIMBadgeView *)badgeView
{
    if (_badgeView == nil) {
        _badgeView = [NIMBadgeView viewWithBadgeTip:@""];
    }
    return _badgeView;
}

- (UIImageView *)muteImageView
{
    if (_muteImageView == nil) {
        _muteImageView = [[UIImageView alloc] init];
        _muteImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _muteImageView;
}

@end
