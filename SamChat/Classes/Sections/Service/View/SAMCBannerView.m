//
//  SAMCBannerView.m
//  SamChat
//
//  Created by HJ on 10/16/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCBannerView.h"

@interface SAMCBannerView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation SAMCBannerView

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
    _gradientLayer = [[CAGradientLayer alloc] init];
    _gradientLayer.startPoint = CGPointMake(0, 1);
    _gradientLayer.endPoint = CGPointMake(1, 1);
    [self.layer addSublayer:_gradientLayer];
}

- (void)updateGradientColors:(NSArray *)colors
{
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    _gradientLayer.colors = cgColors;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
}

@end
