//
//  SAMCPeopleDataCell.m
//  SamChat
//
//  Created by HJ on 10/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPeopleDataCell.h"

@interface SAMCPeopleDataCell ()

@end

@implementation SAMCPeopleDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    _firstNameLabel = [[UILabel alloc] init];
    _firstNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _firstNameLabel.backgroundColor = [UIColor clearColor];
    _firstNameLabel.font = [UIFont systemFontOfSize:17.0f];
    _firstNameLabel.textColor = SAMC_COLOR_INK;
    _firstNameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_firstNameLabel];
    
    _lastNameLabel = [[UILabel alloc] init];
    _lastNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _lastNameLabel.backgroundColor = [UIColor clearColor];
    _lastNameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    _lastNameLabel.textColor = SAMC_COLOR_INK;
    _lastNameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_lastNameLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[_firstNameLabel]-5-[_lastNameLabel]-16-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_firstNameLabel, _lastNameLabel)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_firstNameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_lastNameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [_firstNameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

@end
