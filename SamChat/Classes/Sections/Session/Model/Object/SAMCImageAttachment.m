//
//  SAMCImageAttachment.m
//  SamChat
//
//  Created by HJ on 9/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCImageAttachment.h"
#import "NTESFileLocationHelper.h"
#import "SAMCImageUtil.h"
#import "NSData+NTES.h"
#import "UIImage+NIM.h"
#import "SAMCAccountManager.h"

@implementation SAMCImageAttachment

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        [self updateImage:image];
        self.progress = 0.f;
    }
    return self;
}

- (void)updateImage:(UIImage *)image
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    _displayName = [NSString stringWithFormat:@"图片发送于%@",dateString];
    
    NSString *currentAccount = [SAMCAccountManager sharedManager].currentAccount;
    NSInteger timeInterval = [@([[NSDate date] timeIntervalSince1970] * 1000) integerValue];
    NSString *filename = [NSString stringWithFormat:@"%@_%ld.jpg",currentAccount,timeInterval];
    
    _path = [NSString stringWithFormat:@"org_%@", filename];
    UIImage *orgImage = [SAMCImageUtil scaleImage:image toMaxSize:1280];
    NSData *orgData = UIImageJPEGRepresentation(orgImage, 0.75);
    [orgData writeToFile:self.path atomically:YES];
    
    _thumbPath = _path;
//    self.thumbPath = [NSString stringWithFormat:@"thumb_%@", filename];
//    UIImage *thumbImage = [SAMCImageUtil scaleImage:image toMaxSize:300];
//    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.75);
//    [thumbData writeToFile:self.thumbPath atomically:YES];
    
     _size = orgImage ? orgImage.size : CGSizeZero;
}

#pragma NIMCustomAttachment
- (NSString *)encodeAttachment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [dict setObject:@(CustomMessageTypeSAMCImage) forKey:CMType];
    if ([_url length]) {
        [data setObject:_url forKey:CMURL];
    }
    if ([_thumbUrl length]) {
        [data setObject:_thumbUrl forKey:CMTHUMBURL];
    }
    if ([_path length]) {
        [data setObject:_path forKey:CMPATH];
    }
    if ([_thumbPath length]) {
        [data setObject:_thumbPath forKey:CMTHUMBPATH];
    }
    if ([_displayName length]) {
        [data setObject:_displayName forKey:CMDISPLAYNAME];
    }
    [data setObject:@(_size.height) forKey:CMSIZE_HEIGHT];
    [data setObject:@(_size.width) forKey:CMSIZE_WIDTH];
    [dict setObject:data forKey:CMData];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)path
{
    if (_path) {
        return [NTESFileLocationHelper filepathForImage:_path];
    } else {
        return nil;
    }
}

- (NSString *)thumbPath
{
    if (_thumbPath) {
        return [NTESFileLocationHelper filepathForImage:_thumbPath];
    } else {
        return nil;
    }
}

- (NSString *)filename
{
    return _path;
}

#pragma mark - NTESSessionCustomContentConfig
- (NSString *)cellContent:(NIMMessage *)message
{
    return @"SAMCSessionImageContentView";
}

- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width
{
    CGFloat attachmentImageMinWidth  = (width / 4.0);
    CGFloat attachmentImageMinHeight = (width / 4.0);
    CGFloat attachmemtImageMaxWidth  = (width - 184);
    CGFloat attachmentImageMaxHeight = (width - 184);
    
    CGSize imageSize;
    if (!CGSizeEqualToSize(self.size, CGSizeZero)) {
        imageSize = self.size;
    } else {
        UIImage *image = [UIImage imageWithContentsOfFile:self.thumbPath];
        imageSize = image ? image.size : CGSizeZero;
    }
    CGSize contentSize = [UIImage nim_sizeWithImageOriginSize:imageSize
                                                      minSize:CGSizeMake(attachmentImageMinWidth, attachmentImageMinHeight)
                                                      maxSize:CGSizeMake(attachmemtImageMaxWidth, attachmentImageMaxHeight)];
    return contentSize;
}

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    return message.isOutgoingMsg ? UIEdgeInsetsMake(3-1,3-1,3-1,8+5) : UIEdgeInsetsMake(3-1,8+5,3-1,3-1);
}

@end
