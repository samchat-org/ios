//
//  SAMCOneCodeView.m
//  SamChat
//
//  Created by HJ on 10/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCOneCodeView.h"

@interface SAMCOneCodeView ()

@property (nonatomic, strong) UIView *backgroundView;
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
    _backgroundView = [[UILabel alloc] init];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_backgroundView];
    
    _inputLabel = [[UILabel alloc] init];
    _inputLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _inputLabel.backgroundColor = [UIColor clearColor];
    _inputLabel.textColor = [UIColor whiteColor];
    _inputLabel.font = [UIFont systemFontOfSize:15.0f];
    _inputLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_inputLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_backgroundView]-4-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_backgroundView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[_backgroundView]-4-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_backgroundView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_inputLabel]-4-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_inputLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[_inputLabel]-4-|"
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
        self.backgroundColor = UIColorFromRGB(0xE1EDB8);
        _backgroundView.backgroundColor = UIColorFromRGB(0x7ED321);
        _inputLabel.font = [UIFont systemFontOfSize:15.0f];
    } else {
        self.backgroundColor = [UIColor clearColor];
        _backgroundView.backgroundColor = UIColorFromRGB(0xD8DCE2);
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
