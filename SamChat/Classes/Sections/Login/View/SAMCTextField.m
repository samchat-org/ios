//
//  SAMCTextField.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTextField.h"

@interface SAMCTextField ()

@property (nonatomic, strong) UILabel *splitLabel;

@end

@implementation SAMCTextField


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.layer.cornerRadius = 5.0f;
    
    _leftButton = [[UIButton alloc] init];
    _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    _leftButton.backgroundColor = [UIColor clearColor];
    [self addSubview:_leftButton];
    
    _splitLabel = [[UILabel alloc] init];
    _splitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _splitLabel.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_splitLabel];
    
    _rightTextField = [[UITextField alloc] init];
    _rightTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _rightTextField.backgroundColor = [UIColor clearColor];
    [self addSubview:_rightTextField];
    
    [_leftButton addConstraint:[NSLayoutConstraint constraintWithItem:_leftButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                             constant:70.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_leftButton]-5-[_splitLabel(1)]-20-[_rightTextField]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftButton,_splitLabel,_rightTextField)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_leftButton]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_splitLabel]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_splitLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_rightTextField]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_rightTextField)]];
    [_leftButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}


@end
