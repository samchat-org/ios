//
//  SAMCQRScanLineView.h
//  SamChat
//
//  Created by HJ on 8/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCQRScanLineView : UIImageView

- (void)startAnimatingWithRect:(CGRect)animationRect
                        inView:(UIView*)parentView
                         image:(UIImage*)image;
- (void)stopAnimating;

@end
