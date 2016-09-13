//
//  SAMCSessionImageContentView.m
//  SamChat
//
//  Created by HJ on 9/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSessionImageContentView.h"
#import "SAMCImageAttachment.h"
#import "NIMMessageModel.h"
#import "UIView+NIM.h"
#import "NIMLoadProgressView.h"
#import "SAMCImageUtil.h"

@interface SAMCSessionImageContentView()

@property (nonatomic,strong,readwrite) UIImageView * imageView;

@property (nonatomic,strong) NIMLoadProgressView * progressView;

@end

@implementation SAMCSessionImageContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        self.opaque = YES;
        _imageView  = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_imageView];
        _progressView = [[NIMLoadProgressView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _progressView.maxProgress = 1.0f;
        [self addSubview:_progressView];
        
    }
    return self;
}

- (void)refresh:(NIMMessageModel *)model{
    [super refresh:model];
    NIMCustomObject * customObject = (NIMCustomObject*)model.message.messageObject;
    SAMCImageAttachment *attachment = (SAMCImageAttachment *)customObject.attachment;
    
    UIImage *image = [UIImage imageWithContentsOfFile:attachment.thumbPath];
    self.imageView.image = image;
    self.progressView.hidden     = model.message.isOutgoingMsg ? (model.message.deliveryState != NIMMessageDeliveryStateDelivering) : (model.message.attachmentDownloadState != NIMMessageAttachmentDownloadStateDownloading);
    if (!self.progressView.hidden) {
        [self.progressView setProgress:attachment.progress];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    CGSize contentSize = self.model.contentSize;
    CGRect imageViewFrame = CGRectMake(contentInsets.left, contentInsets.top, contentSize.width, contentSize.height);
    self.imageView.frame  = imageViewFrame;
    _progressView.frame   = self.bounds;
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.cornerRadius = 13.0;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.frame = self.imageView.bounds;
    self.imageView.layer.mask = maskLayer;
}


- (void)onTouchUpInside:(id)sender
{
    NIMKitEvent *event = [[NIMKitEvent alloc] init];
    event.eventName = NIMKitEventNameTapContent;
    event.messageModel = self.model;
    [self.delegate onCatchEvent:event];
}

- (void)updateProgress:(float)progress
{
    if (progress > 1.0) {
        progress = 1.0;
    }
    self.progressView.progress = progress;
}

@end