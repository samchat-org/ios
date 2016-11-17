//
//  SAMCSyncManager.h
//  SamChat
//
//  Created by HJ on 9/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCSyncManager : NSObject

+ (instancetype)sharedManager;

- (void)start;
- (void)close;

- (void)updateLocalContactListVersionFrom:(NSString *)fromVersion
                                       to:(NSString *)toVersion
                                     type:(SAMCContactListType)listType;
- (void)updateLocalFollowListVersionFrom:(NSString *)fromVersion
                                      to:(NSString *)toVersion;

@end
