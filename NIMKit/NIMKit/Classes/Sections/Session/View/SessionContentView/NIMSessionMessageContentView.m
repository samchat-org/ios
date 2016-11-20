//
//  NIMSessionMessageContentView.m
//  NIMKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMSessionMessageContentView.h"
#import "NIMMessageModel.h"
#import "UIImage+NIM.h"

@implementation NIMSessionMessageContentView

- (instancetype)initSessionMessageContentView
{
    CGSize defaultBubbleSize = CGSizeMake(60, 35);
    if (self = [self initWithFrame:CGRectMake(0, 0, defaultBubbleSize.width, defaultBubbleSize.height)]) {
        [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        _bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,defaultBubbleSize.width,defaultBubbleSize.height)];
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bubbleImageView];
    }
    return self;
}

- (void)refresh:(NIMMessageModel*)data{
    _model = data;
    CGSize size = [self bubbleViewSize:data];
    self.bounds = CGRectMake(0, 0, size.width, size.height);
    [_bubbleImageView setImage:[self chatBubbleImageForState:UIControlStateNormal
                                                    outgoing:data.message.isOutgoingMsg
                                                      spMode:_model.isSPMode]];
    [_bubbleImageView setHighlightedImage:[self chatBubbleImageForState:UIControlStateHighlighted
                                                               outgoing:data.message.isOutgoingMsg
                                                                 spMode:_model.isSPMode]];
    _bubbleImageView.frame = self.bounds;
    [self setNeedsLayout];
}


- (void)layoutSubviews{
    [super layoutSubviews];
}


- (void)updateProgress:(float)progress
{
    
}

- (void)onTouchDown:(id)sender
{
    
}

- (void)onTouchUpInside:(id)sender
{
    
}

- (void)onTouchUpOutside:(id)sender{
    
}


#pragma mark - Private
// SAMC_BEGIN
//- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing
- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing spMode:(BOOL)spMode
// SAMC_END
{
    if (outgoing) {
        if (state == UIControlStateNormal)
        {
            // SAMC_BEGIN
//            UIImage *image = [UIImage nim_imageInKit:@"icon_sender_text_node_normal.png"];
//            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18,25,17,25) resizingMode:UIImageResizingModeStretch];
            UIImage *image;
            if (spMode) {
                image = [UIImage nim_imageInKit:@"bkg-chat-ingra-right.png"];
            } else {
                image = [UIImage nim_imageInKit:@"bkg-chat-green-right.png"];
            }
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(21,15,10,26) resizingMode:UIImageResizingModeStretch];
            // SAMC_END
        }else if (state == UIControlStateHighlighted)
        {
            // SAMC_BEGIN
//            UIImage *image = [UIImage nim_imageInKit:@"icon_sender_text_node_pressed.png"] ;
//            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18,25,17,25) resizingMode:UIImageResizingModeStretch];
            UIImage *image;
            if (spMode) {
                image = [UIImage nim_imageInKit:@"bkg-chat-ingra-right-pressed.png"];
            } else {
                image = [UIImage nim_imageInKit:@"bkg-chat-green-right-pressed.png"];
            }
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(21,15,10,26) resizingMode:UIImageResizingModeStretch];
            // SAMC_END
        }
        
    }else {
        if (state == UIControlStateNormal) {
            // SAMC_BEGIN
//            UIImage *image = [UIImage nim_imageInKit:@"icon_receiver_node_normal.png"];
//            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18,25,17,25) resizingMode:UIImageResizingModeStretch];
            UIImage *image = [UIImage nim_imageInKit:@"bkg-chat-white-left.png"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(21,26,10,15) resizingMode:UIImageResizingModeStretch];
            // SAMC_END
        }else if (state == UIControlStateHighlighted) {
            // SAMC_BEGIN
//            UIImage *image = [UIImage nim_imageInKit:@"icon_receiver_node_pressed.png"] ;
//            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18,25,17,25) resizingMode:UIImageResizingModeStretch];
            UIImage *image = [UIImage nim_imageInKit:@"bkg-chat-white-left-pressed.png"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(21,26,10,15) resizingMode:UIImageResizingModeStretch];
            // SAMC_END
        }
    }
    return nil;
}


- (CGSize)bubbleViewSize:(NIMMessageModel *)model
{
    CGSize bubbleSize;
    CGSize contentSize  = model.contentSize;
    UIEdgeInsets insets = model.contentViewInsets;
    bubbleSize.width  = contentSize.width + insets.left + insets.right;
    bubbleSize.height = contentSize.height + insets.top + insets.bottom;
    return bubbleSize;
}


- (void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    _bubbleImageView.highlighted = highlighted;
}

@end
