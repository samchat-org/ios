//
//  SAMCPreferenceManager.m
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPreferenceManager.h"

#define SAMC_CURRENTUSERMODE_KEY    @"samc_currentusermode_key"
#define SAMC_GETUIBINDEDALIAS_KEY   @"samc_getuibindedalias_key"
#define SAMC_FOLLOWLISTSYNCFLAG_KEY @"samc_followlistsyncflag_key"

@interface SAMCPreferenceManager ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation SAMCPreferenceManager

@synthesize currentUserMode = _currentUserMode;
@synthesize getuiBindedAlias = _getuiBindedAlias;
@synthesize followListSyncFlag = _followListSyncFlag;

+ (instancetype)sharedManager
{
    static SAMCPreferenceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCPreferenceManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _syncQueue = dispatch_queue_create("com.github.gknows.samchat.preferenceQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - currentUserMode
- (NSNumber *)currentUserMode
{
    __block NSNumber *mode;
    dispatch_sync(_syncQueue, ^{
        if (_currentUserMode == nil) {
            _currentUserMode = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_CURRENTUSERMODE_KEY];
            _currentUserMode = _currentUserMode ?: @(SAMCUserModeTypeCustom);
        }
        mode = _currentUserMode;
    });
    return mode;
}

- (void)setCurrentUserMode:(NSNumber *)currentUserMode
{
    dispatch_barrier_async(_syncQueue, ^{
        _currentUserMode = currentUserMode;
        [[NSUserDefaults standardUserDefaults] setValue:currentUserMode forKey:SAMC_CURRENTUSERMODE_KEY];
    });
}

#pragma mark - getuiBindedAlias
- (NSString *)getuiBindedAlias
{
    __block NSString *alias;
    dispatch_sync(_syncQueue, ^{
        if (_getuiBindedAlias) {
            _getuiBindedAlias = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_GETUIBINDEDALIAS_KEY];
        }
        alias = _getuiBindedAlias;
    });
    return alias;
}

- (void)setGetuiBindedAlias:(NSString *)getuiBindedAlias
{
    dispatch_barrier_async(_syncQueue, ^{
        _getuiBindedAlias = getuiBindedAlias;
        [[NSUserDefaults standardUserDefaults] setValue:getuiBindedAlias forKey:SAMC_GETUIBINDEDALIAS_KEY];
    });
}

#pragma mark - followListSyncFlag
- (NSNumber *)followListSyncFlag
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_followListSyncFlag == nil) {
            _followListSyncFlag = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_FOLLOWLISTSYNCFLAG_KEY];
            _followListSyncFlag = _followListSyncFlag ?:@(NO);
        }
        flag = _followListSyncFlag;
    });
    return flag;
}

- (void)setFollowListSyncFlag:(NSNumber *)followListSyncFlag
{
    dispatch_barrier_async(_syncQueue, ^{
        _followListSyncFlag = followListSyncFlag;
        [[NSUserDefaults standardUserDefaults] setValue:followListSyncFlag forKey:SAMC_FOLLOWLISTSYNCFLAG_KEY];
    });
}

@end
