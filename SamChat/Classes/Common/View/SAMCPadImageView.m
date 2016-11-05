//
//  SAMCPadImageView.m
//  SamChat
//
//  Created by HJ on 10/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPadImageView.h"

@interface SAMCPadImageView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SAMCPadImageView

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectMake(0, 0, 40, 40)];
    if (self) {
        [self setupSubviews:image hpadding:7.5f vpadding:7.5f];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image hpadding:(CGFloat)hpadding vpadding:(CGFloat)vpadding
{
    self = [super initWithFrame:CGRectMake(0, 0, 40+(hpadding-vpadding)*2, 40)];
    if (self) {
        [self setupSubviews:image hpadding:hpadding vpadding:vpadding];
    }
    return self;
}

- (void)setupSubviews:(UIImage *)image hpadding:(CGFloat)hpadding vpadding:(CGFloat)vpadding
{
    _imageView = [[UIImageView alloc] initWithImage:image];
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

- (UIImage *)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

@end
