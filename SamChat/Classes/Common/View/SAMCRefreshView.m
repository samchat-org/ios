//
//  SAMCRefreshView.m
//  SamChat
//
//  Created by HJ on 10/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRefreshView.h"

@interface SAMCRefreshBaseView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SAMCRefreshBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    _activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:_activityIndicatorView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = SAMC_COLOR_GREY;
    _titleLabel.text = @"searching";
    [self addSubview:_titleLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_activityIndicatorView]-5-[_titleLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_activityIndicatorView,_titleLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_titleLabel)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_titleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)startAnimating
{
    _titleLabel.text = @"searching";
    [_activityIndicatorView startAnimating];
}

- (void)stopAnimating
{
    _titleLabel.text = @"No more results";
    [_activityIndicatorView stopAnimating];
}

@end


@interface SAMCRefreshView ()

@property (nonatomic, strong) SAMCRefreshBaseView *refreshBaseView;

@end

@implementation SAMCRefreshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    _refreshBaseView = [[SAMCRefreshBaseView alloc] init];
    _refreshBaseView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_refreshBaseView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_refreshBaseView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_refreshBaseView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)startAnimating
{
    [_refreshBaseView startAnimating];
}

- (void)stopAnimating
{
    [_refreshBaseView stopAnimating];
}

@end
