//
//  SAMCResponseAvatarsView.m
//  SamChat
//
//  Created by HJ on 10/10/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCResponseAvatarsView.h"
#import "SAMCAvatarImageView.h"

@interface SAMCResponseAvatarsView ()

@property (nonatomic, strong) NSArray<SAMCAvatarImageView *> *avatarImageViewArray;

@end

@implementation SAMCResponseAvatarsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    for (SAMCAvatarImageView *imageView in self.avatarImageViewArray) {
        [self addSubview:imageView];
    }
    for (SAMCAvatarImageView *imageView in self.avatarImageViewArray) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:imageView
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"view":imageView}]];
    }
    NSDictionary *views = @{@"imageView1":_avatarImageViewArray[2],
                            @"imageView2":_avatarImageViewArray[1],
                            @"imageView3":_avatarImageViewArray[0]};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView1]-5-[imageView2(==imageView1)]-5-[imageView3(==imageView1)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

- (void)updateAvatars:(NSArray<NIMKitInfo *> *)infos
{
    NSInteger count = [infos count];
    if (count > 3) {
        infos = [infos subarrayWithRange:NSMakeRange(0, 3)];
    }
    int index = 0;
    for (index = 0; index < count; index++) {
        SAMCAvatarImageView *imageView = _avatarImageViewArray[index];
        NIMKitInfo *info = infos[index];
        NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
        [imageView samc_setImageWithURL:url placeholderImage:info.avatarImage options:SDWebImageRetryFailed];
    }
    for (; index < 2; index++) {
        SAMCAvatarImageView *imageView = _avatarImageViewArray[index];
        imageView.image = nil;
    }
}

#pragma mark - lazy load
- (NSArray<SAMCAvatarImageView *> *)avatarImageViewArray
{
    if (_avatarImageViewArray == nil) {
        _avatarImageViewArray = @[[SAMCAvatarImageView new], [SAMCAvatarImageView new], [SAMCAvatarImageView new]];
        for (SAMCAvatarImageView *imageView in _avatarImageViewArray) {
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    return _avatarImageViewArray;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (SAMCAvatarImageView *imageView in _avatarImageViewArray) {
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.layer.masksToBounds = YES;
    }
}

@end
