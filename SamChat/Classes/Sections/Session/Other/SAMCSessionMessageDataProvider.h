//
//  SAMCSessionMessageDataProvider.h
//  SamChat
//
//  Created by HJ on 8/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCSessionMessageDataProvider : NSObject<NIMKitMessageProvider>

- (instancetype)initWithSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode;

@end
