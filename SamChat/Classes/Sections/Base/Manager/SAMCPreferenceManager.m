//
//  SAMCPreferenceManager.m
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPreferenceManager.h"

#define SAMC_CURRENTUSERMODE_KEY            @"samc_currentusermode_key"
#define SAMC_GETUIBINDEDALIAS_KEY           @"samc_getuibindedalias_key"
#define SAMC_SENDCLIENTIDFLAG_KEY           @"samc_sendclientidflag_key"
#define SAMC_LOCALFOLLOWLISTVERSION_KEY     @"samc_localfollowlistversion_key"
#define SAMC_LOCALCUSTOMERLISTVERSION_KEY   @"samc_localcustomerlistversion_key"
#define SAMC_LOCALSERVICERLISTVERSION_KEY   @"samc_localservicerlistversion_key"

@interface SAMCPreferenceManager ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation SAMCPreferenceManager

@synthesize currentUserMode = _currentUserMode;
@synthesize getuiBindedAlias = _getuiBindedAlias;
@synthesize sendClientIdFlag = _sendClientIdFlag;
@synthesize localFollowListVersion = _localFollowListVersion;
@synthesize localCustomerListVersion = _localCustomerListVersion;
@synthesize localServicerListVersion = _localServicerListVersion;

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

- (void)reset
{
    dispatch_barrier_async(_syncQueue, ^{
        _currentUserMode = @(SAMCUserModeTypeCustom);
        [[NSUserDefaults standardUserDefaults] setValue:_currentUserMode forKey:SAMC_CURRENTUSERMODE_KEY];
        _getuiBindedAlias = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_getuiBindedAlias forKey:SAMC_GETUIBINDEDALIAS_KEY];
        _sendClientIdFlag = @(NO);
        [[NSUserDefaults standardUserDefaults] setValue:_sendClientIdFlag forKey:SAMC_SENDCLIENTIDFLAG_KEY];
        _localFollowListVersion = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_localFollowListVersion forKey:SAMC_LOCALFOLLOWLISTVERSION_KEY];
        _localServicerListVersion = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_localServicerListVersion forKey:SAMC_LOCALSERVICERLISTVERSION_KEY];
        _localCustomerListVersion = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_localCustomerListVersion forKey:SAMC_LOCALCUSTOMERLISTVERSION_KEY];
    });
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
        if (_getuiBindedAlias == nil) {
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

#pragma mark - localFollowListVersion
- (NSString *)localFollowListVersion
{
    __block NSString *version;
    dispatch_sync(_syncQueue, ^{
        if (_localFollowListVersion == nil) {
            _localFollowListVersion = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_LOCALFOLLOWLISTVERSION_KEY];
            _localFollowListVersion = _localFollowListVersion ?:@"";
        }
        version = _localFollowListVersion;
    });
    return version;
}

- (void)setLocalFollowListVersion:(NSString *)localFollowListVersion
{
    dispatch_barrier_async(_syncQueue, ^{
        _localFollowListVersion = localFollowListVersion;
        [[NSUserDefaults standardUserDefaults] setValue:localFollowListVersion forKey:SAMC_LOCALFOLLOWLISTVERSION_KEY];
    });
}

#pragma mark - localCustomerListVersion
- (NSString *)localCustomerListVersion
{
    __block NSString *version;
    dispatch_sync(_syncQueue, ^{
        if (_localCustomerListVersion == nil) {
            _localCustomerListVersion = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_LOCALCUSTOMERLISTVERSION_KEY];
            _localCustomerListVersion = _localCustomerListVersion ?:@"";
        }
        version = _localCustomerListVersion;
    });
    return version;
}

- (void)setLocalCustomerListVersion:(NSString *)localCustomerListVersion
{
    dispatch_barrier_async(_syncQueue, ^{
        _localCustomerListVersion = localCustomerListVersion;
        [[NSUserDefaults standardUserDefaults] setValue:localCustomerListVersion forKey:SAMC_LOCALCUSTOMERLISTVERSION_KEY];
    });
}

#pragma mrak - localServicerListVersion
- (NSString *)localServicerListVersion
{
    __block NSString *version;
    dispatch_sync(_syncQueue, ^{
        if (_localServicerListVersion == nil) {
            _localServicerListVersion = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_LOCALSERVICERLISTVERSION_KEY];
            _localServicerListVersion = _localServicerListVersion ?:@"";
        }
        version = _localServicerListVersion;
    });
    return version;
}

- (void)setLocalServicerListVersion:(NSString *)localServicerListVersion
{
    dispatch_barrier_async(_syncQueue, ^{
        _localServicerListVersion = localServicerListVersion;
        [[NSUserDefaults standardUserDefaults] setValue:localServicerListVersion forKey:SAMC_LOCALSERVICERLISTVERSION_KEY];
    });
}

#pragma mark - sendClientIdFlag
- (NSNumber *)sendClientIdFlag
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_sendClientIdFlag == nil) {
            _sendClientIdFlag = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_SENDCLIENTIDFLAG_KEY];
            _sendClientIdFlag = _sendClientIdFlag ?:@(NO);
        }
        flag = _sendClientIdFlag;
    });
    return flag;
}

- (void)setSendClientIdFlag:(NSNumber *)sendClientIdFlag
{
    dispatch_barrier_async(_syncQueue, ^{
        _sendClientIdFlag = sendClientIdFlag;
        [[NSUserDefaults standardUserDefaults] setValue:sendClientIdFlag forKey:SAMC_SENDCLIENTIDFLAG_KEY];
    });
}

@end
