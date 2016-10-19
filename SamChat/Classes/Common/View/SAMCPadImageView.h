//
//  SAMCPadImageView.h
//  SamChat
//
//  Created by HJ on 10/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCPadImageView : UIView

- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image hpadding:(CGFloat)hpadding vpadding:(CGFloat)vpadding;

@end
