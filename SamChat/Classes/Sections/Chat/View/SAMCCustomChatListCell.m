//
//  SAMCCustomChatListCell.m
//  SamChat
//
//  Created by HJ on 10/12/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomChatListCell.h"
#import "SAMCAvatarImageView.h"
#import "SAMCSession.h"
#import "NIMKitUtil.h"

@interface SAMCCustomChatListCell ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *dotLabel;

@end

@implementation SAMCCustomChatListCell

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
    [self addSubview:self.dotLabel];
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
                                                             constant:40.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [_dotLabel addConstraint:[NSLayoutConstraint constraintWithItem:_dotLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_dotLabel
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_avatarView]-5-[_nameLabel]-5-[_categoryLabel]-5-[_dotLabel(6)][_timeLabel]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_nameLabel,_categoryLabel,_dotLabel,_timeLabel)]];
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
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_dotLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarView]-5-[_messageLabel]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_messageLabel)]];
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
    [_nameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_categoryLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_categoryLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _dotLabel.layer.cornerRadius = _dotLabel.frame.size.width/2;
}

- (void)setRecentSession:(SAMCRecentSession *)recentSession
{
//    self.nameLabel.text = [self nameForRecentSession:recentSession];
    self.messageLabel.text = recentSession.lastMessageContent;
    self.timeLabel.text = [self timestampDescriptionForRecentSession:recentSession];
    
    
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:recentSession.session.sessionId
                                            inSession:recentSession.session.nimSession];
    
    NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
    [self.avatarView samc_setImageWithURL:url placeholderImage:info.avatarImage options:SDWebImageRetryFailed];
    
    self.categoryLabel.text = info.serviceCategory;
    if (recentSession.unreadCount) {
        self.avatarView.circleColor = SAMC_COLOR_LIME;
    } else {
        self.avatarView.circleColor = SAMC_COLOR_LIGHTGREY;
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
    self.nameLabel.text = name;
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
        _nameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _nameLabel.textColor = SAMC_MAIN_DARKCOLOR;
    }
    return _nameLabel;
}

- (UILabel *)categoryLabel
{
    if (_categoryLabel == nil) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _categoryLabel.font = [UIFont systemFontOfSize:14.0f];
        _categoryLabel.textColor = SAMC_MAIN_DARKCOLOR;
    }
    return _categoryLabel;
}

- (UILabel *)dotLabel
{
    if (_dotLabel == nil) {
        _dotLabel = [[UILabel alloc] init];
        _dotLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _dotLabel.backgroundColor = UIColorFromRGB(0x7ED321);
        _dotLabel.layer.masksToBounds = YES;
    }
    return _dotLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        _timeLabel.textColor = UIColorFromRGB(0xC3C3C3);
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
        _messageLabel.textColor = UIColorFromRGB(0x767B82);
    }
    return _messageLabel;
}

@end
