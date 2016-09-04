//
//  SAMCPublicSessionConfig.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSessionConfig.h"

@interface SAMCPublicSessionConfig ()

@end

@implementation SAMCPublicSessionConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)mediaItems
{
    return @[[NIMMediaItem item:NTESMediaButtonPicture
                    normalImage:[UIImage imageNamed:@"bk_media_picture_normal"]
                  selectedImage:[UIImage imageNamed:@"bk_media_picture_nomal_pressed"]
                          title:@"相册"] ];
}

- (id<NIMKitMessageProvider>)messageDataProvider
{
    return nil;
}

- (BOOL)shouldHandleReceipt{
    return NO;
}

@end
