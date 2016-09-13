//
//  SAMCImageAttachment.h
//  SamChat
//
//  Created by HJ on 9/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachmentDefines.h"

@interface SAMCImageAttachment : NSObject<NIMCustomAttachment,NTESCustomAttachmentInfo>

- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *thumbPath;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *thumbUrl;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat progress;

@end
