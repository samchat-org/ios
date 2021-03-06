//
//  SAMCUnreadCountManager.h
//  SamChat
//
//  Created by HJ on 9/16/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCUnreadCountManagerDelegate.h"

@interface SAMCUnreadCountManager : NSObject

@property (nonatomic, assign) NSInteger customChatUnreadCount;
@property (nonatomic, assign) NSInteger customPublicUnreadCount;
@property (nonatomic, assign) NSInteger customServiceUnreadCount;

@property (nonatomic, assign) NSInteger spChatUnreadCount;
@property (nonatomic, assign) NSInteger spPublicUnreadCount;
@property (nonatomic, assign) NSInteger spServiceUnreadCount;

+ (instancetype)sharedManager;
- (void)start;
- (void)close;

- (void)addDelegate:(id<SAMCUnreadCountManagerDelegate>)delegate;
- (void)removeDelegate:(id<SAMCUnreadCountManagerDelegate>)delegate;


- (NSInteger)chatUnreadCountOfUserMode:(SAMCUserModeType)mode;
- (NSInteger)serviceUnreadCountOfUserMode:(SAMCUserModeType)mode;
- (NSInteger)publicUnreadCountOfUserMode:(SAMCUserModeType)mode;

- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)mode;
- (NSInteger)allUnreadCount;

@end
