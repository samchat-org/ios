//
//  SAMCCustomPublicListCell.m
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomPublicListCell.h"

@implementation SAMCCustomPublicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
//        _avatarImageView = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//        [self addSubview:_avatarImageView];
//        
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _nameLabel.backgroundColor = [UIColor whiteColor];
//        _nameLabel.font            = [UIFont systemFontOfSize:15.f];
//        [self addSubview:_nameLabel];
//        
//        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _messageLabel.backgroundColor = [UIColor whiteColor];
//        _messageLabel.font            = [UIFont systemFontOfSize:14.f];
//        _messageLabel.textColor       = [UIColor lightGrayColor];
//        [self addSubview:_messageLabel];
//        
//        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _timeLabel.backgroundColor = [UIColor whiteColor];
//        _timeLabel.font            = [UIFont systemFontOfSize:14.f];
//        _timeLabel.textColor       = [UIColor lightGrayColor];
//        [self addSubview:_timeLabel];
//        
//        _badgeView = [NIMBadgeView viewWithBadgeTip:@""];
//        [self addSubview:_badgeView];
    }
    return self;
}

- (void)setupSubviews
{
    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.layer.cornerRadius = 20.0f;
    _avatarImageView.backgroundColor = [UIColor redColor];
    [self addSubview:_avatarImageView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.backgroundColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:15.0f];
    [self addSubview:_nameLabel];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _messageLabel.backgroundColor = [UIColor whiteColor];
    _messageLabel.font = [UIFont systemFontOfSize:14.0f];
    _messageLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_messageLabel];
    
    [_avatarImageView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_avatarImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_avatarImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(40)]-5-[_messageLabel]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarImageView,_messageLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_nameLabel]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_messageLabel]-15-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_messageLabel)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_messageLabel
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
}

@end
