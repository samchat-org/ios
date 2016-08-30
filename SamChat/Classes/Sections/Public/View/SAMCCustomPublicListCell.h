//
//  SAMCCustomPublicListCell.h
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCAvatarImageView.h"

@interface SAMCCustomPublicListCell : UITableViewCell

@property (nonatomic, strong) SAMCAvatarImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end
