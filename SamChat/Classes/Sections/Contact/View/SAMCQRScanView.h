//
//  SAMCQRScanView.h
//  SamChat
//
//  Created by HJ on 8/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCQRScanView : UIView

-(id)initWithFrame:(CGRect)frame;

- (void)startDeviceReadyingWithText:(NSString*)text;
- (void)stopDeviceReadying;

- (void)startScanAnimation;
- (void)stopScanAnimation;

+ (CGRect)getScanRectWithPreView:(UIView*)view;

@end
