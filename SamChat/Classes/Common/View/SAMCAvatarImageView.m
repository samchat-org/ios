//
//  SAMCAvatarImageView.m
//  SamChat
//
//  Created by HJ on 10/20/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAvatarImageView.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"

static char imageURLKey;

@interface SAMCAvatarImageView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SAMCAvatarImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithCircleWidth:0.0f];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame circleWidth:(CGFloat)width
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithCircleWidth:width];
    }
    return self;
}

- (void)setupSubviewsWithCircleWidth:(CGFloat)width
{
    self.circleColor = SAMC_COLOR_LIGHTGREY;
    self.backgroundColor = [UIColor clearColor];
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.layer.masksToBounds = YES;
    [self addSubview:_imageView];
    
    NSString *constraints = [NSString stringWithFormat:@"H:|-%f-[_imageView]-%f-|", width, width];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_imageView)]];
    constraints = [NSString stringWithFormat:@"V:|-%f-[_imageView]-%f-|", width, width];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_imageView)]];
}

- (void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    self.backgroundColor = circleColor;
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat length = MIN(self.frame.size.width, self.frame.size.height);
    self.layer.cornerRadius = length/2;
    length = MIN(_imageView.frame.size.width, _imageView.frame.size.height);
    _imageView.layer.cornerRadius = length/2;
}

- (UIImage *)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)image
{
    if (image == nil) {
        self.backgroundColor = [UIColor clearColor];
    } else {
        self.backgroundColor = self.circleColor;
    }
    _imageView.image = image;
}

@end

@implementation SAMCAvatarImageView (SDWebImageCache)

- (void)samc_setImageWithURL:(NSURL *)url {
    [self samc_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self samc_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self samc_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)samc_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self samc_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self samc_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self samc_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)samc_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self samc_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock)
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)samc_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self samc_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];
}

- (NSURL *)samc_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}


- (void)samc_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)samc_cancelCurrentAnimationImagesLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}

@end
