//
//  SAMCCardPortraitView.m
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCardPortraitView.h"
#import "SAMCAvatarImageView.h"
#import "UIImageView+WebCache.h"

@interface SAMCCardPortraitView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *shadowView;

@end

@implementation SAMCCardPortraitView

- (instancetype)initWithFrame:(CGRect)frame effect:(BOOL)effect
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews:effect];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews:YES];
    }
    return self;
}

- (void)setupSubviews:(BOOL)effect
{
    self.backgroundColor = [UIColor clearColor];
    if (effect) {
        [self setupEffect];
    }
    [self addSubview:self.shadowView];
    [self addSubview:self.avatarView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_shadowView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_shadowView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [_shadowView addConstraint:[NSLayoutConstraint constraintWithItem:_shadowView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_shadowView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0f
                                                             constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_shadowView]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_shadowView)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [_avatarView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_avatarView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0f
                                                             constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_avatarView]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView)]];
}

- (void)setupEffect
{
    [self addSubview:self.backgroundImageView];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundImageView addSubview:effectView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImageView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_backgroundImageView)]];
    
    [_backgroundImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[effectView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(effectView)]];
    [_backgroundImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[effectView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(effectView)]];
}

#pragma mark - 
- (void)layoutSubviews
{
    [super layoutSubviews];
    _shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_shadowView.bounds cornerRadius:_shadowView.bounds.size.height/2].CGPath;
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    _avatarUrl = avatarUrl;
    NSURL *url = [avatarUrl length] ? [NSURL URLWithString:avatarUrl] : nil;
    [_avatarView samc_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_user"] options:SDWebImageRetryFailed];
    [_backgroundImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_user"] options:SDWebImageRetryFailed];
}

#pragma mark - lazy load
- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.layer.masksToBounds = YES;
    }
    return _backgroundImageView;
}

- (UIView *)shadowView
{
    if (_shadowView == nil) {
        _shadowView = [[UIView alloc] init];
        _shadowView.translatesAutoresizingMaskIntoConstraints = NO;
        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.layer.shadowColor = SAMC_COLOR_INK.CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
        _shadowView.layer.shadowOpacity = 0.5;
        _shadowView.layer.shadowRadius = 3;
    }
    return _shadowView;
}

- (SAMCAvatarImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[SAMCAvatarImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.circleColor = [UIColor whiteColor];
    }
    return _avatarView;
}

@end
