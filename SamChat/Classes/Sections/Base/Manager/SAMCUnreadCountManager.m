//
//  SAMCUnreadCountManager.m
//  SamChat
//
//  Created by HJ on 9/16/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUnreadCountManager.h"
#import "SAMCConversationManager.h"
#import "GCDMulticastDelegate.h"
#import "SAMCDataBaseManager.h"

@interface SAMCUnreadCountManager ()<SAMCConversationManagerDelegate>

@property (nonatomic, strong) GCDMulticastDelegate<SAMCUnreadCountManagerDelegate> *multicastDelegate;

@end

@implementation SAMCUnreadCountManager

+ (instancetype)sharedManager
{
    static SAMCUnreadCountManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCUnreadCountManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _multicastDelegate = (GCDMulticastDelegate <SAMCUnreadCountManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
        [[SAMCConversationManager sharedManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[SAMCConversationManager sharedManager] removeDelegate:self];
}

- (void)refresh
{
    _customChatUnreadCount = [[SAMCDataBaseManager sharedManager].messageDB allUnreadCountOfUserMode:SAMCUserModeTypeCustom];
    _spChatUnreadCount = [[SAMCDataBaseManager sharedManager].messageDB allUnreadCountOfUserMode:SAMCUserModeTypeSP];
}

- (void)clear
{
    self.customChatUnreadCount = 0;
    self.customPublicUnreadCount = 0;
    self.customServiceUnreadCount = 0;
    self.spChatUnreadCount = 0;
    self.spPublicUnreadCount = 0;
    self.spServiceUnreadCount = 0;
}

- (void)addDelegate:(id<SAMCUnreadCountManagerDelegate>)delegate
{
    [self.multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<SAMCUnreadCountManagerDelegate>)delegate
{
    [self.multicastDelegate removeDelegate:delegate];
}

- (NSInteger)chatUnreadCountOfUserMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        return self.customChatUnreadCount;
    } else {
        return self.spChatUnreadCount;
    }
}

#pragma mark - Property
- (void)setCustomChatUnreadCount:(NSInteger)customChatUnreadCount
{
    if (_customChatUnreadCount != customChatUnreadCount) {
        _customChatUnreadCount = customChatUnreadCount;
        [self.multicastDelegate chatUnreadCountDidChanged:customChatUnreadCount mode:SAMCUserModeTypeCustom];
    }
}

- (void)setSpChatUnreadCount:(NSInteger)spChatUnreadCount
{
    if (_spChatUnreadCount != spChatUnreadCount) {
        _spChatUnreadCount = spChatUnreadCount;
        [self.multicastDelegate chatUnreadCountDidChanged:spChatUnreadCount mode:SAMCUserModeTypeSP];
    }
}

#pragma mark - Private
- (void)updateChatUnreadCount:(NSInteger)count userMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        self.customChatUnreadCount = count;
    } else {
        self.spChatUnreadCount = count;
    }
}

#pragma mark - SAMCConversationManagerDelegate
- (void)didAddRecentSession:(SAMCRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    [self updateChatUnreadCount:totalUnreadCount userMode:recentSession.session.sessionMode];
}

- (void)didUpdateRecentSession:(SAMCRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    [self updateChatUnreadCount:totalUnreadCount userMode:recentSession.session.sessionMode];
}

- (void)didRemoveRecentSession:(SAMCRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    [self updateChatUnreadCount:totalUnreadCount userMode:recentSession.session.sessionMode];
}

- (void)messagesDeletedInSession:(SAMCSession *)session
{
    // TODO:
}

- (void)allMessagesDeleted
{
    // TODO:
}

@end
