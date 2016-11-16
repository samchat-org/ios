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
#define SAMC_LOCALFOLLOWLISTVERSION_KEY     @"samc_localfollowlistversion_key"
#define SAMC_LOCALCUSTOMERLISTVERSION_KEY   @"samc_localcustomerlistversion_key"
#define SAMC_LOCALSERVICERLISTVERSION_KEY   @"samc_localservicerlistversion_key"
#define SAMC_NEEDQUESTIONNOTIFY_KEY         @"samc_needquestionnotify_key"
#define SAMC_NEEDSOUND_KEY                  @"samc_needsound_key"
#define SAMC_NEEDVIBRATE_KEY                @"samc_needvibrate_key"

@interface SAMCPreferenceManager ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation SAMCPreferenceManager

@synthesize currentUserMode = _currentUserMode;
@synthesize localFollowListVersion = _localFollowListVersion;
@synthesize localCustomerListVersion = _localCustomerListVersion;
@synthesize localServicerListVersion = _localServicerListVersion;
@synthesize needQuestionNotify = _needQuestionNotify;
@synthesize needSound = _needSound;
@synthesize needVibrate = _needVibrate;

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
        _localFollowListVersion = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_localFollowListVersion forKey:SAMC_LOCALFOLLOWLISTVERSION_KEY];
        _localServicerListVersion = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_localServicerListVersion forKey:SAMC_LOCALSERVICERLISTVERSION_KEY];
        _localCustomerListVersion = @"";
        [[NSUserDefaults standardUserDefaults] setValue:_localCustomerListVersion forKey:SAMC_LOCALCUSTOMERLISTVERSION_KEY];
        _needQuestionNotify = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needQuestionNotify forKey:SAMC_NEEDQUESTIONNOTIFY_KEY];
        _needSound = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needSound forKey:SAMC_NEEDSOUND_KEY];
        _needVibrate = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needVibrate forKey:SAMC_NEEDVIBRATE_KEY];
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

#pragma mark - needQuestionNotify
- (NSNumber *)needQuestionNotify
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_needQuestionNotify == nil) {
            _needQuestionNotify = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_NEEDQUESTIONNOTIFY_KEY];
            _needQuestionNotify = _needQuestionNotify ?:@(YES);
        }
        flag = _needQuestionNotify;
    });
    return flag;
}

- (void)setNeedQuestionNotify:(NSNumber *)needQuestionNotify
{
    dispatch_barrier_async(_syncQueue, ^{
        _needQuestionNotify = needQuestionNotify;
        [[NSUserDefaults standardUserDefaults] setValue:needQuestionNotify forKey:SAMC_NEEDQUESTIONNOTIFY_KEY];
    });
}

#pragma mark - needSound
- (NSNumber *)needSound
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_needSound == nil) {
            _needSound = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_NEEDSOUND_KEY];
            _needSound = _needSound ?:@(YES);
        }
        flag = _needSound;
    });
    return flag;
}

- (void)setNeedSound:(NSNumber *)needSound
{
    dispatch_barrier_async(_syncQueue, ^{
        _needSound = needSound;
        [[NSUserDefaults standardUserDefaults] setValue:needSound forKey:SAMC_NEEDSOUND_KEY];
    });
}

#pragma mark - needVibrate
- (NSNumber *)needVibrate
{
    __block NSNumber *flag;
    dispatch_sync(_syncQueue, ^{
        if (_needVibrate == nil) {
            _needVibrate = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_NEEDVIBRATE_KEY];
            _needVibrate = _needVibrate ?:@(YES);
        }
        flag = _needVibrate;
    });
    return flag;
}

- (void)setNeedVibrate:(NSNumber *)needVibrate
{
    dispatch_barrier_async(_syncQueue, ^{
        _needVibrate = needVibrate;
        [[NSUserDefaults standardUserDefaults] setValue:needVibrate forKey:SAMC_NEEDVIBRATE_KEY];
    });
}

@end
