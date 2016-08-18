//
//  SAMCTextView.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTextView.h"

@interface SAMCTextView ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation SAMCTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)dealloc
{
    DDLogDebug(@"delloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
}

- (void)setupSubviews
{
    self.font = [UIFont systemFontOfSize:17.0f];
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = [UIFont systemFontOfSize:17.0f];
    _placeholderLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_placeholderLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_placeholderLabel]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_placeholderLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_placeholderLabel]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_placeholderLabel)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChanged)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

- (void)textDidChanged
{
    _placeholderLabel.hidden = self.hasText;
}

- (NSString *)placeholder
{
    return _placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [_placeholderLabel setText:placeholder];
}

@end
