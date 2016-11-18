//
//  SAMCCustomPublicListCell.h
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCAvatarImageView.h"
#import "SAMCPublicSession.h"

@interface SAMCCustomPublicListCell : UITableViewCell

@property (nonatomic, strong) SAMCPublicSession *publicSession;

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;

@end
