//
//  SAMCPadImageView.m
//  SamChat
//
//  Created by HJ on 10/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPadImageView.h"

@implementation SAMCPadImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithhpadding:10.0f vpadding:10.0f];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame hpadding:(CGFloat)hpadding vpadding:(CGFloat)vpadding
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithhpadding:hpadding vpadding:vpadding];
    }
    return self;
}

- (void)setupSubviewsWithhpadding:(CGFloat)hpadding vpadding:(CGFloat)vpadding
{
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];
    
    NSString *format = [NSString stringWithFormat:@"H:|-%f-[_imageView]-%f-|", hpadding, hpadding];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_imageView)]];
    format = [NSString stringWithFormat:@"V:|-%f-[_imageView]-%f-|", vpadding, vpadding];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_imageView)]];
}

@end
