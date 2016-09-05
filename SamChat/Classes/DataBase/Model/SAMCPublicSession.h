//
//  SAMCPublicSession.h
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCSPBasicInfo.h"

@interface SAMCPublicSession : NSObject

@property (nonatomic, strong) SAMCSPBasicInfo *spBasicInfo;
@property (nonatomic, assign) NSInteger uniqueId;
@property (nonatomic, copy) NSString *lastMessageContent;
@property (nonatomic, assign) BOOL isOutgoing;

@property (nonatomic, copy) NSString *tableName;

+ (instancetype)session:(SAMCSPBasicInfo *)info
     lastMessageContent:(NSString *)messageContent;

+ (instancetype)sessionOfMyself;

@end
