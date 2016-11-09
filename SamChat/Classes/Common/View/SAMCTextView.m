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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
}

- (void)setupSubviews
{
    self.font = [UIFont systemFontOfSize:15.0f];
    self.textContainerInset = UIEdgeInsetsMake(10, 20, 10, 20);
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.textAlignment = NSTextAlignmentLeft;
    _placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _placeholderLabel.font = [UIFont systemFontOfSize:15.0f];
    _placeholderLabel.textColor = [UIColor lightGrayColor];
    _placeholderLabel.numberOfLines = 0;
    [self addSubview:_placeholderLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_placeholderLabel]-25-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_placeholderLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_placeholderLabel]"
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

- (void)setText:(NSString *)text
{
    [super setText:text];
    _placeholderLabel.hidden = [text length];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _placeholderLabel.preferredMaxLayoutWidth = self.bounds.size.width-40.0f;
}

@end
