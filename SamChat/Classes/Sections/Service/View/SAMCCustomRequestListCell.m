//
//  SAMCCustomRequestListCell.m
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomRequestListCell.h"

@implementation SAMCCustomRequestListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
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
    _messageLabel.backgroundColor = [UIColor whiteColor];
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.numberOfLines = 0;
    _messageLabel.font = [UIFont systemFontOfSize:15.f];
    _messageLabel.textColor = UIColorFromRGB(0x7D7D7D);
    [self.contentView addSubview:_messageLabel];
    
    _locationLabel = [[UILabel alloc] init];
    _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _locationLabel.backgroundColor = [UIColor whiteColor];
    _locationLabel.font = [UIFont systemFontOfSize:14.0f];
    _locationLabel.textColor = UIColorFromRGB(0x565656);
    [self.contentView addSubview:_locationLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeLabel.backgroundColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:14.0f];
    _timeLabel.textColor = UIColorFromRGB(0x565656);
    [self.contentView addSubview:_timeLabel];
    
}

@end
