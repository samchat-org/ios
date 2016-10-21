//
//  SAMCCardPortraitView.h
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCAvatarImageView.h"

@interface SAMCCardPortraitView : UIView

@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) SAMCAvatarImageView *avatarView;

- (instancetype)initWithFrame:(CGRect)frame effect:(BOOL)effect;

@end
