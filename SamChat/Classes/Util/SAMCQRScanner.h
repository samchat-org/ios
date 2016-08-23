//
//  SAMCQRScanner.h
//  SamChat
//
//  Created by HJ on 8/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SAMCQRScanner : NSObject

- (instancetype)initWithPreView:(UIView*)preView
                       cropRect:(CGRect)cropRect
                     completion:(void(^)(NSArray<NSString*> *result))completion;

- (void)startScan;

- (void)stopScan;

- (void)openFlash:(BOOL)bOpen;

- (void)openOrCloseFlash;

+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor;

+ (void)systemVibrate;

#pragma mark - Permission
+ (BOOL)isGetCameraPermission;
+ (BOOL)isGetPhotoPermission;

@end
