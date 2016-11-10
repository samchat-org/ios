//
//  SAMCUnreadCountManager.m
//  SamChat
//
//  Created by HJ on 9/16/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUnreadCountManager.h"
#import "SAMCConversationManager.h"
#import "SAMCQuestionManager.h"
#import "GCDMulticastDelegate.h"
#import "SAMCDataBaseManager.h"
#import "SAMCPublicManager.h"

@interface SAMCUnreadCountManager ()<SAMCConversationManagerDelegate,SAMCQuestionManagerDelegate,SAMCPublicManagerDelegate>

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
    }
    return self;
}

- (void)dealloc
{
    [self close];
}

- (void)start
{
    _multicastDelegate = (GCDMulticastDelegate <SAMCUnreadCountManagerDelegate> *)[[GCDMulticastDelegate alloc] init];
    [self refresh];
    [[SAMCConversationManager sharedManager] addDelegate:self];
    [[SAMCQuestionManager sharedManager] addDelegate:self];
    [[SAMCPublicManager sharedManager] addDelegate:self];
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].apnsManager registerBadgeCountHandler:^NSUInteger{
        return [wself allUnreadCount];
    }];
}

- (void)close
{
    [[SAMCConversationManager sharedManager] removeDelegate:self];
    [[SAMCQuestionManager sharedManager] removeDelegate:self];
    [[SAMCPublicManager sharedManager] removeDelegate:self];
    [self clear];
}

- (void)refresh
{
    SAMCDataBaseManager *dbManager = [SAMCDataBaseManager sharedManager];
    _customChatUnreadCount = [dbManager.messageDB allUnreadCountOfUserMode:SAMCUserModeTypeCustom];
    _spChatUnreadCount = [dbManager.messageDB allUnreadCountOfUserMode:SAMCUserModeTypeSP];
    _customServiceUnreadCount = [dbManager.questionDB allUnreadCountOfUserMode:SAMCUserModeTypeCustom];
    _spServiceUnreadCount = [dbManager.questionDB allUnreadCountOfUserMode:SAMCUserModeTypeSP];
    _customPublicUnreadCount = [dbManager.publicDB allUnreadCountOfUserMode:SAMCUserModeTypeCustom];
    _spPublicUnreadCount = 0;
}

- (void)clear
{
    _customChatUnreadCount = 0;
    _customPublicUnreadCount = 0;
    _customServiceUnreadCount = 0;
    _spChatUnreadCount = 0;
    _spServiceUnreadCount = 0;
    _spPublicUnreadCount = 0;
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

- (NSInteger)serviceUnreadCountOfUserMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        return self.customServiceUnreadCount;
    } else {
        return self.spServiceUnreadCount;
    }
}

- (NSInteger)publicUnreadCountOfUserMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        return self.customPublicUnreadCount;
    } else {
        return self.spPublicUnreadCount;
    }
}

- (NSInteger)allUnreadCountOfUserMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        return self.customChatUnreadCount+self.customPublicUnreadCount+self.customServiceUnreadCount;
    } else {
        return self.spChatUnreadCount+self.spPublicUnreadCount+self.spServiceUnreadCount;
    }
}

- (NSInteger)allUnreadCount
{
    return self.customChatUnreadCount+ self.customPublicUnreadCount+self.customServiceUnreadCount
    + self.spChatUnreadCount+self.spPublicUnreadCount+self.spServiceUnreadCount;
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

- (void)setCustomServiceUnreadCount:(NSInteger)customServiceUnreadCount
{
    if (_customServiceUnreadCount != customServiceUnreadCount) {
        _customServiceUnreadCount = customServiceUnreadCount;
        [self.multicastDelegate serviceUnreadCountDidChanged:customServiceUnreadCount mode:SAMCUserModeTypeCustom];
    }
}

- (void)setSpServiceUnreadCount:(NSInteger)spServiceUnreadCount
{
    if (_spServiceUnreadCount != spServiceUnreadCount) {
        _spServiceUnreadCount = spServiceUnreadCount;
        [self.multicastDelegate serviceUnreadCountDidChanged:spServiceUnreadCount mode:SAMCUserModeTypeSP];
    }
}

- (void)setCustomPublicUnreadCount:(NSInteger)customPublicUnreadCount
{
    if (_customPublicUnreadCount != customPublicUnreadCount) {
        _customPublicUnreadCount = customPublicUnreadCount;
        [self.multicastDelegate publicUnreadCountDidChanged:customPublicUnreadCount mode:SAMCUserModeTypeCustom];
    }
}

#pragma mark - SAMCConversationManagerDelegate
- (void)totalUnreadCountDidChanged:(NSInteger)totalUnreadCount userMode:(SAMCUserModeType)mode;
{
    if (mode == SAMCUserModeTypeCustom) {
        self.customChatUnreadCount = totalUnreadCount;
    } else {
        self.spChatUnreadCount = totalUnreadCount;
    }
}

#pragma mark - SAMCQuestionManagerDelegate
- (void)questionUnreadCountDidChanged:(NSInteger)unreadCount userMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        self.customServiceUnreadCount = unreadCount;
    } else {
        self.spServiceUnreadCount = unreadCount;
    }
}

#pragma mark - SAMCPublicManagerDelegate
- (void)publicUnreadCountDidChanged:(NSInteger)unreadCount userMode:(SAMCUserModeType)mode
{
    if (mode == SAMCUserModeTypeCustom) {
        self.customPublicUnreadCount = unreadCount;
    }
}

@end
