//
//  SAMCPublicSessionConfig.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSessionConfig.h"
#import "SAMCPublicMessageDataProvider.h"

@interface SAMCPublicSessionConfig ()

@property (nonatomic, strong) SAMCPublicMessageDataProvider *provider;
@property (nonatomic, strong) SAMCPublicSession *publicSession;

@end

@implementation SAMCPublicSessionConfig

- (instancetype)initWithSession:(SAMCPublicSession *)session
{
    self = [super init];
    if (self) {
        self.publicSession = session;
        self.provider = [[SAMCPublicMessageDataProvider alloc] initWithSession:session];
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
    return self.provider;
}

- (BOOL)shouldHandleReceipt{
    return NO;
}

@end
