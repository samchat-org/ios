//
//  SAMCTextField.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTextField.h"

@interface SAMCTextField ()


@end

@implementation SAMCTextField


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    
    _leftButton = [[UIButton alloc] init];
    _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    _leftButton.exclusiveTouch = YES;
    [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    _leftButton.backgroundColor = [UIColor clearColor];
    _leftButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self addSubview:_leftButton];
    
    _splitLabel = [[UILabel alloc] init];
    _splitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _splitLabel.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.3);
    [self addSubview:_splitLabel];
    
    _rightTextField = [[UITextField alloc] init];
    _rightTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _rightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _rightTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _rightTextField.backgroundColor = [UIColor clearColor];
    _rightTextField.font = [UIFont systemFontOfSize:17.0f];
//    [_rightTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [self addSubview:_rightTextField];
    
    [_leftButton addConstraint:[NSLayoutConstraint constraintWithItem:_leftButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                             constant:30.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_leftButton]-15-[_splitLabel(1)]-5-[_rightTextField]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftButton,_splitLabel,_rightTextField)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftButton]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[_splitLabel]-1-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_splitLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightTextField]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_rightTextField)]];
    [_leftButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    // fix the issue: text bounces after resigning first responder
//    [textField layoutIfNeeded];
//}

- (BOOL)becomeFirstResponder
{
    return [_rightTextField becomeFirstResponder];
}

@end
