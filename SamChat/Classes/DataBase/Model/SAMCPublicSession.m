//
//  SAMCPublicSession.m
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSession.h"

@implementation SAMCPublicSession

+ (instancetype)session:(SAMCSPBasicInfo *)info
     lastMessageContent:(NSString *)messageContent
{
    SAMCPublicSession *session = [[SAMCPublicSession alloc] init];
    session.spBasicInfo = info;
    session.lastMessageContent = messageContent;
    return session;
}

@end
