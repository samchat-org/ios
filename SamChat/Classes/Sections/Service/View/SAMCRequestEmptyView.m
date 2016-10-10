//
//  SAMCRequestEmptyView.m
//  SamChat
//
//  Created by HJ on 10/10/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRequestEmptyView.h"

@interface SAMCRequestEmptyView ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation SAMCRequestEmptyView

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
    [self addSubview:self.logoImageView];
    [self addSubview:self.tipLabel];
    [self addSubview:self.detailLabel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tipLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_tipLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_detailLabel]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_detailLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_logoImageView]-20-[_tipLabel]-10-[_detailLabel]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_logoImageView,_tipLabel,_detailLabel)]];
}

- (void)setDaysEarlier:(NSInteger)daysEarlier
{
    if (daysEarlier == 0) {
        self.logoImageView.image = [UIImage imageNamed:@"request_logo_today"];
        self.tipLabel.text = @"Request sent!";
        self.detailLabel.text = @"We are on the hunt for the best service providers. We will let you know soon!";
    } else if (daysEarlier == 1) {
        self.logoImageView.image = [UIImage imageNamed:@"request_logo_oneday"];
        self.tipLabel.text = @"Looking for service providers";
        self.detailLabel.text = @"Hang on there, we are on this!";
    } else if (daysEarlier == 2) {
        self.logoImageView.image = [UIImage imageNamed:@"request_logo_twodays"];
        self.tipLabel.text = @"Still looking for service providers";
        self.detailLabel.text = @"We haven't given up yet. We will leave no rocks unturned";
    } else {
        self.logoImageView.image = [UIImage imageNamed:@"request_logo_threedays"];
        self.tipLabel.text = @"No service providers responded...";
        self.detailLabel.text = @"Well that was kinda embarrassing. How about try another search instead?";
    }
}

#pragma mark - lazy load
- (UIImageView *)logoImageView
{
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logoImageView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
        _tipLabel.textColor = SAMC_MAIN_DARKCOLOR;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.font = [UIFont systemFontOfSize:12.0f];
        _detailLabel.textColor = SAMC_MAIN_LIGHTCOLOR;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 0;
    }
    return _detailLabel;
}

@end
