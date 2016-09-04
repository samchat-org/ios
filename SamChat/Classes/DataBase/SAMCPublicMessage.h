//
//  SAMCPublicMessage.h
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMMessageWrapper.h"

@class SAMCPublicSession;

@interface SAMCPublicMessage : NIMMessageWrapper

@property (nonatomic, strong) SAMCPublicSession *publicSession;

@property (nonatomic, assign) NSInteger serverId;

@end
