//
//  SAMCPublicMessageDataProvider.m
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMessageDataProvider.h"

@interface SAMCPublicMessageDataProvider ()

@property (nonatomic, strong) SAMCPublicSession *session;

@end

@implementation SAMCPublicMessageDataProvider

- (instancetype)initWithSession:(SAMCPublicSession *)session
{
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)pullDown:(NIMMessage *)firstMessage handler:(NIMKitDataProvideHandler)handler
{
}

- (BOOL)needTimetag{
    return YES;
}

@end