//
//  SAMCSPRequestListCell.m
//  SamChat
//
//  Created by HJ on 10/20/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPRequestListCell.h"
#import "SAMCAvatarImageView.h"

@interface SAMCSPRequestListCell ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation SAMCSPRequestListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
        self.separatorInset = UIEdgeInsetsZero;
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.avatarView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.locationLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.messageLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[_avatarView(30)]-10-[_nameLabel]-10-[_timeLabel]-16-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_nameLabel,_timeLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[_messageLabel]-16-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_messageLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarView]-10-[_locationLabel]-16-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_locationLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarView(30)]-12-[_messageLabel]-16-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_messageLabel)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_nameLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_timeLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_locationLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)updateWithSession:(SAMCQuestionSession *)questionSession
{
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:[@(questionSession.senderId) stringValue]];
    NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
    [_avatarView samc_setImageWithURL:url placeholderImage:info.avatarImage options:SDWebImageRetryFailed];
    if (questionSession.status == SAMCReceivedQuestionStatusNew) {
        _avatarView.circleColor = SAMC_COLOR_LIME;
    } else {
        _avatarView.circleColor = SAMC_COLOR_LIGHTGREY;
    }
    _nameLabel.text = questionSession.senderUsername;
    _locationLabel.text = questionSession.address;
    _timeLabel.text = questionSession.questionTimeDescription;
    _messageLabel.text = questionSession.question;
}

#pragma mark - lazy load
- (SAMCAvatarImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[SAMCAvatarImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont systemFontOfSize:13.0f];
        _nameLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel *)locationLabel
{
    if (_locationLabel == nil) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _locationLabel.font = [UIFont systemFontOfSize:13.0f];
        _locationLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        _locationLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _locationLabel;
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
        _messageLabel.textColor = SAMC_COLOR_INK;
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.numberOfLines = 2;
    }
    return _messageLabel;
}

@end
