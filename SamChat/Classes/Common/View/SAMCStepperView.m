//
//  SAMCStepperView.m
//  SamChat
//
//  Created by HJ on 10/17/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCStepperView.h"

@interface SAMCStepperCircleView : UIView

@property (nonatomic, strong) UILabel *inLabel;
@property (nonatomic, strong) UILabel *middleLabel;
@property (nonatomic, strong) UILabel *outLabel;

@end

@implementation SAMCStepperCircleView

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
    _outLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _outLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _outLabel.backgroundColor = [UIColor clearColor];
    _outLabel.layer.cornerRadius = 9.0f;
    _outLabel.layer.masksToBounds = YES;
    [self addSubview:_outLabel];
    [_outLabel addConstraint:[NSLayoutConstraint constraintWithItem:_outLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_outLabel
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [_outLabel addConstraint:[NSLayoutConstraint constraintWithItem:_outLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:0.0f
                                                           constant:18.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_outLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_outLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];

    _middleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _middleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _middleLabel.backgroundColor = UIColorFromRGB(0xE0E4E8);
    _middleLabel.layer.cornerRadius = 6.0f;
    _middleLabel.layer.masksToBounds = YES;
    [self addSubview:_middleLabel];
    [_middleLabel addConstraint:[NSLayoutConstraint constraintWithItem:_middleLabel
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_middleLabel
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0f
                                                              constant:0.0f]];
    [_middleLabel addConstraint:[NSLayoutConstraint constraintWithItem:_middleLabel
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:12.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_middleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_middleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    _inLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _inLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _inLabel.backgroundColor = SAMC_COLOR_LIMEGREY;
    _inLabel.layer.cornerRadius = 3.0f;
    _inLabel.layer.masksToBounds = YES;
    [self addSubview:_inLabel];
    [_inLabel addConstraint:[NSLayoutConstraint constraintWithItem:_inLabel
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_inLabel
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    [_inLabel addConstraint:[NSLayoutConstraint constraintWithItem:_inLabel
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0f
                                                          constant:6.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_inLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_inLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

@end


@interface SAMCStepperView ()

@property (nonatomic, strong) SAMCStepperCircleView *leftView;
@property (nonatomic, strong) SAMCStepperCircleView *middleView;
@property (nonatomic, strong) SAMCStepperCircleView *rightView;
@property (nonatomic, strong) UILabel *lineLabel;

@end

@implementation SAMCStepperView

- (id)initWithFrame:(CGRect)frame step:(NSInteger)step color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews:step color:color];
    }
    return self;
}

- (void)setupSubviews:(NSInteger)step color:(UIColor *)color
{
    self.backgroundColor = [UIColor clearColor];
    _lineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _lineLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _lineLabel.backgroundColor = SAMC_COLOR_LIMEGREY;
    [self addSubview:_lineLabel];
    [_lineLabel addConstraint:[NSLayoutConstraint constraintWithItem:_lineLabel
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:0.0f
                                                            constant:1.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_lineLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9-[_lineLabel]-9-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_lineLabel)]];
    
    
    _leftView = [[SAMCStepperCircleView alloc] init];
    _leftView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_leftView];
    
    _middleView = [[SAMCStepperCircleView alloc] init];
    _middleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_middleView];
    
    _rightView = [[SAMCStepperCircleView alloc] init];
    _rightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_rightView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftView(12)]-18-[_middleView(12)]-18-[_rightView(12)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftView,_middleView,_rightView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_middleView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_middleView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_rightView)]];
    
    SAMCStepperCircleView *stepView;
    if (step == 1) {
        stepView = _leftView;
    } else if (step == 2) {
        stepView = _middleView;
    } else {
        stepView = _rightView;
    }
    stepView.outLabel.backgroundColor = SAMC_COLOR_LIGHTGREY;
    stepView.middleLabel.backgroundColor = color;
    stepView.inLabel.backgroundColor = [UIColor clearColor];
}

@end