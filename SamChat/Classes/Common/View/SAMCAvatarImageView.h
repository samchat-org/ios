//
//  SAMCAvatarImageView.h
//  SamChat
//
//  Created by HJ on 10/20/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"

@interface SAMCAvatarImageView : UIControl

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, copy) NSString *userId;

- (instancetype)initWithFrame:(CGRect)frame circleWidth:(CGFloat)width;

@end

@interface SAMCAvatarImageView (SDWebImageCache)
- (NSURL *)samc_imageURL;

- (void)samc_setImageWithURL:(NSURL *)url;
- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;
- (void)samc_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;
- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;
- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;
- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
- (void)samc_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
- (void)samc_cancelCurrentImageLoad;
- (void)samc_cancelCurrentAnimationImagesLoad;
@end
