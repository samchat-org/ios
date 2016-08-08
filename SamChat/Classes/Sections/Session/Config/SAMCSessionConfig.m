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

- (instancetype)initWithSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode
{
    self = [super init];
    if (self) {
        self.provider = [[SAMCSessionMessageDataProvider alloc] initWithSession:session userMode:userMode];
    }
    return self;
}

- (id<NIMKitMessageProvider>)messageDataProvider
{
    return self.provider;
}

@end
