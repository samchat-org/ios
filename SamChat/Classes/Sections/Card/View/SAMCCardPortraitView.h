//
//  SAMCCardPortraitView.h
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCCardPortraitView : UIView

@property (nonatomic, strong) NSString *avatarUrl;

- (instancetype)initWithFrame:(CGRect)frame effect:(BOOL)effect;

@end
