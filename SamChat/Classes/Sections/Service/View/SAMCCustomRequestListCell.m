//
//  SAMCCustomRequestListCell.m
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomRequestListCell.h"
#import "NIMBadgeView.h"
#import "SAMCResponseAvatarsView.h"

@interface SAMCCustomRequestListCell ()

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) SAMCResponseAvatarsView *avatarsView;

@end

@implementation SAMCCustomRequestListCell

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
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.locationLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.avatarsView];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_messageLabel]-5-[_avatarsView]-10-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_messageLabel,_avatarsView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_messageLabel]-5-[_locationLabel]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_messageLabel,_locationLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_timeLabel]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_timeLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarsView(20)]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_avatarsView)]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_locationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_locationLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_timeLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_avatarsView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
}

- (void)updateWithSession:(SAMCQuestionSession *)questionSession
{
    self.messageLabel.text = questionSession.question;
    self.locationLabel.text = questionSession.address;
    self.timeLabel.text = [questionSession responseTimeDescription];
    
    NSMutableArray *answersInfos = [[NSMutableArray alloc] init];
    for (NSString *userId in questionSession.answers) {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:userId];
        [answersInfos addObject:info];
    }
    [self.avatarsView updateAvatars:answersInfos];
}

#pragma mark - lazy load
- (UILabel *)messageLabel
{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.numberOfLines = 2;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.font = [UIFont systemFontOfSize:15.f];
        _messageLabel.textColor = SAMC_MAIN_DARKCOLOR;
    }
    return _messageLabel;
}

- (UILabel *)locationLabel
{
    if (_locationLabel == nil) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _locationLabel.backgroundColor = [UIColor clearColor];
        _locationLabel.font = [UIFont systemFontOfSize:12.0f];
        _locationLabel.textColor = UIColorFromRGB(0x89949D);
    }
    return _locationLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = UIColorFromRGB(0xBDBDBD);
    }
    return _timeLabel;
}

- (SAMCResponseAvatarsView *)avatarsView
{
    if (_avatarsView == nil) {
        _avatarsView = [[SAMCResponseAvatarsView alloc] init];
        _avatarsView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _avatarsView;
}

@end
