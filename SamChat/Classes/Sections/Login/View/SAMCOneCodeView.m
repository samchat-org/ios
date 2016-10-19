//
//  SAMCOneCodeView.m
//  SamChat
//
//  Created by HJ on 10/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCOneCodeView.h"

@interface SAMCOneCodeView ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UILabel *inputLabel;

@end

@implementation SAMCOneCodeView

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
    _backgroundView = [[UIImageView alloc] init];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundView.contentMode = UIViewContentModeCenter;
    [self addSubview:_backgroundView];
    
    _inputLabel = [[UILabel alloc] init];
    _inputLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _inputLabel.backgroundColor = [UIColor clearColor];
    _inputLabel.textColor = [UIColor whiteColor];
    _inputLabel.font = [UIFont systemFontOfSize:15.0f];
    _inputLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_inputLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_backgroundView]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_backgroundView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_backgroundView]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_backgroundView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_inputLabel]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_inputLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_inputLabel]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_inputLabel)]];
    [self inputText:@""];
}

- (void)inputText:(NSString *)text
{
    if ([text length] != 1) {
        text = @"";
    }
    _inputLabel.text = text;
    if ([text length]) {
        self.backgroundColor = UIColorFromRGBA(SAMC_COLOR_RGB_LEMMON, 0.3);
        _backgroundView.backgroundColor = SAMC_COLOR_LIME;
        _backgroundView.image = nil;
        _inputLabel.font = [UIFont systemFontOfSize:17.0f];
    } else {
        self.backgroundColor = [UIColor clearColor];
        _backgroundView.backgroundColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.1);
        _backgroundView.image = [UIImage imageNamed:@"ico_code"];
        _inputLabel.font = [UIFont systemFontOfSize:27.0f];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
    _backgroundView.layer.cornerRadius = _backgroundView.frame.size.width/2;
    _backgroundView.layer.masksToBounds = YES;
}

@end
