//
//  SAMCPublicManagerDelegate.h
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCPublicSession.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SAMCPublicManagerDelegate <NSObject>

@optional
- (void)didAddPublicSession:(SAMCPublicSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount;

@end

NS_ASSUME_NONNULL_END