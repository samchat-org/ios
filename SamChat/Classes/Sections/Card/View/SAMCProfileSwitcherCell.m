//
//  SAMCProfileSwitcherCell.m
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCProfileSwitcherCell.h"

@implementation SAMCProfileSwitcherCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    _switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
    _switcher.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_switcher];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_switcher
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_switcher
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0f
                                                      constant:-15.0f]];
}

@end
