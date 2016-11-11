//
//  SAMCFooterView.m
//  SamChat
//
//  Created by HJ on 11/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCFooterView.h"

@implementation SAMCFooterView

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
    self.backgroundColor = [UIColor clearColor];
    _textLabel = [[UILabel alloc] init];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.font = [UIFont systemFontOfSize:14.0f];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
    _textLabel.textAlignment = NSTextAlignmentLeft;
    _textLabel.numberOfLines = 0;
    [self addSubview:_textLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_textLabel]-15-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_textLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_textLabel]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_textLabel)]];
}

@end
