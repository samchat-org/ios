//
//  SAMCSessionConfig.m
//  SamChat
//
//  Created by HJ on 8/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSessionConfig.h"
#import "SAMCSessionMessageDataProvider.h"

@interface SAMCSessionConfig ()

@property (nonatomic, strong) SAMCSessionMessageDataProvider *provider;

@end

@implementation SAMCSessionConfig

- (instancetype)initWithSession:(SAMCSession *)samcsession
{
    self = [super init];
    if (self) {
        self.session = [samcsession nimSession];
        self.userMode = samcsession.sessionMode;
        self.provider = [[SAMCSessionMessageDataProvider alloc] initWithSession:samcsession];
    }
    return self;
}

- (NSArray<NSNumber *> *)inputBarItemTypes{
    return @[
      @(NIMInputBarItemTypeVoice),
      @(NIMInputBarItemTypeTextAndRecord),
//      @(NIMInputBarItemTypeEmoticon),
      @(NIMInputBarItemTypeMore),
      ];
}

- (NSArray *)mediaItems
{
    return @[[NIMMediaItem item:NTESMediaButtonPicture
                    normalImage:[UIImage imageNamed:@"bk_media_picture_normal"]
                  selectedImage:[UIImage imageNamed:@"bk_media_picture_pressed"]
                          title:@"Photos"],
             
             [NIMMediaItem item:NTESMediaButtonShoot
                    normalImage:[UIImage imageNamed:@"bk_media_shoot_normal"]
                  selectedImage:[UIImage imageNamed:@"bk_media_shoot_pressed"]
                          title:@"Camera"],
             
//             [NIMMediaItem item:NTESMediaButtonLocation
//                    normalImage:[UIImage imageNamed:@"bk_media_position_normal"]
//                  selectedImage:[UIImage imageNamed:@"bk_media_position_pressed"]
//                          title:@"位置"],
             
             [NIMMediaItem item:NTESMediaButtonAudioChat
                    normalImage:[UIImage imageNamed:@"btn_media_telphone_message_normal"]
                  selectedImage:[UIImage imageNamed:@"btn_media_telphone_message_pressed"]
                          title:@"Audio Call"],
             
//             [NIMMediaItem item:NTESMediaButtonVideoChat
//                    normalImage:[UIImage imageNamed:@"btn_bk_media_video_chat_normal"]
//                  selectedImage:[UIImage imageNamed:@"btn_bk_media_video_chat_pressed"]
//                          title:@"Video Call"],
             
             [NIMMediaItem item:NTESMediaButtonFileTrans
                    normalImage:[UIImage imageNamed:@"icon_file_trans_normal"]
                  selectedImage:[UIImage imageNamed:@"icon_file_trans_pressed"]
                          title:@"Transfer"],
            ];
}

- (id<NIMKitMessageProvider>)messageDataProvider
{
    if (self.session.sessionType != NIMSessionTypeP2P) {
        return nil;
    }
    return self.provider;
}

- (BOOL)shouldHandleReceipt{
    return NO;
}

@end
