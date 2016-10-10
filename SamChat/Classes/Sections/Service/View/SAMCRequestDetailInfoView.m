//
//  SAMCRequestDetailInfoView.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRequestDetailInfoView.h"

@interface SAMCRequestDetailInfoView ()

@property (nonatomic, strong) UIImageView *statusBannerImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@end

@implementation SAMCRequestDetailInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.statusBannerImageView];
    [self addSubview:self.timeLabel];
    [self addSubview:self.infoLabel];
    [self addSubview:self.locationLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_statusBannerImageView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_statusBannerImageView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_timeLabel]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_timeLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_infoLabel]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_infoLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_locationLabel]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_locationLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_statusBannerImageView(4)]-5-[_timeLabel]-5-[_infoLabel]-5-[_locationLabel]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_statusBannerImageView,_timeLabel,_infoLabel,_locationLabel)]];
    
}

- (void)setQuestionSession:(SAMCQuestionSession *)questionSession
{
    _questionSession = questionSession;
    self.timeLabel.text = [questionSession responseTimeDescription];
    self.infoLabel.text = questionSession.question;
    self.locationLabel.text = questionSession.address;
    if ([[questionSession answers] count]) {
        self.statusBannerImageView.image = [UIImage imageNamed:@"request_banner_answered"];
    } else {
        NSInteger daysEarlier = [questionSession daysEarlier];
        if (daysEarlier < 3) {
            self.statusBannerImageView.image = [UIImage imageNamed:@"request_banner_new"];
        } else {
            self.statusBannerImageView.image = [UIImage imageNamed:@"request_banner_embarass"];
        }
    }
}

#pragma mark - lazy load
- (UIImageView *)statusBannerImageView
{
    if (_statusBannerImageView == nil) {
        _statusBannerImageView = [[UIImageView alloc] init];
        _statusBannerImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _statusBannerImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _statusBannerImageView;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.font = [UIFont systemFontOfSize:10.0f];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UILabel *)infoLabel
{
    if (_infoLabel == nil) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _infoLabel.font = [UIFont systemFontOfSize:15.0f];
        _infoLabel.textColor = SAMC_MAIN_DARKCOLOR;
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.numberOfLines = 0;
        _infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _infoLabel;
}

- (UILabel *)locationLabel
{
    if (_locationLabel == nil) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _locationLabel.font = [UIFont systemFontOfSize:10.0f];
        _locationLabel.textColor = SAMC_MAIN_DARKCOLOR;
        _locationLabel.textAlignment = NSTextAlignmentLeft;
        
        _locationLabel.text = _questionSession.address;
    }
    return _locationLabel;
}


@end
