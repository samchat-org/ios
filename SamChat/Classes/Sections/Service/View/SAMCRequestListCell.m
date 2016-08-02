//
//  SAMCRequestListCell.m
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRequestListCell.h"
#import "NIMBadgeView.h"

@implementation SAMCRequestListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
        //self.accessoryType = UITableViewCellAccessoryDetailButton;
        self.separatorInset = UIEdgeInsetsZero;
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return self;
}

- (void)setupSubviews
{
    self.contentView.backgroundColor = UIColorFromRGB(0xECECEC);
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.numberOfLines = 0;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = [UIFont systemFontOfSize:16.f];
    _messageLabel.textColor = UIColorFromRGB(0x7D7D7D);
    [self.contentView addSubview:_messageLabel];
    
    _leftLabel = [[UILabel alloc] init];
    _leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _leftLabel.backgroundColor = [UIColor clearColor];
    _leftLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _leftLabel.textColor = UIColorFromRGB(0x565656);
    [self.contentView addSubview:_leftLabel];
    
    _middleLabel = [[UILabel alloc] init];
    _middleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _middleLabel.backgroundColor = [UIColor clearColor];
    _middleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    _middleLabel.textColor = UIColorFromRGB(0x565656);
    [self.contentView addSubview:_middleLabel];
    
    _rightLabel = [[UILabel alloc] init];
    _rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _rightLabel.backgroundColor = [UIColor clearColor];
    _rightLabel.font = [UIFont boldSystemFontOfSize:14.f];
    _rightLabel.textColor = UIColorFromRGB(0x565656);
    [self.contentView addSubview:_rightLabel];
    
    _accessoryButton = [[UIButton alloc] init];
    _accessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_accessoryButton setBackgroundImage:[UIImage imageNamed:@"bk_media_tip_normal"] forState:UIControlStateNormal];
    [_accessoryButton setBackgroundImage:[UIImage imageNamed:@"bk_media_tip_pressed"] forState:UIControlStateHighlighted];
    [self.contentView addSubview:_accessoryButton];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_messageLabel]-10-[_accessoryButton(40)]-10-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_messageLabel,_accessoryButton)]];
    [_accessoryButton addConstraint:[NSLayoutConstraint constraintWithItem:_accessoryButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_accessoryButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_accessoryButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_leftLabel(80)]-5-[_middleLabel(80)]-5-[_rightLabel]-60-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_leftLabel,_middleLabel,_rightLabel)]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_middleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_leftLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_middleLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_leftLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rightLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_leftLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rightLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_leftLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_messageLabel]-5-[_leftLabel(16)]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_messageLabel,_leftLabel)]];
}

@end
