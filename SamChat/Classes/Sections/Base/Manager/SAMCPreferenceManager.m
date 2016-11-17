//
//  SAMCPreferenceManager.m
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPreferenceManager.h"
#import "SAMCDeviceUtil.h"

#define NIMAccount      @"account"
#define NIMToken        @"token"

@interface SAMCLoginData ()

@end

@implementation SAMCLoginData

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _account = [aDecoder decodeObjectForKey:NIMAccount];
        _token = [aDecoder decodeObjectForKey:NIMToken];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if ([_account length]) {
        [encoder encodeObject:_account forKey:NIMAccount];
    }
    if ([_token length]) {
        [encoder encodeObject:_token forKey:NIMToken];
    }
}

- (NSString *)finalToken
{
    return [_token stringByAppendingString:[SAMCDeviceUtil deviceId]];
}

@end

#define SAMC_CURRENTUSERMODE_KEY            @"samc_currentusermode_key"
#define SAMC_LOGINDATA_KEY                  @"samc_logindata_key"
#define SAMC_GETUIBINDEDALIAS_KEY           @"samc_getuibindedalias_key"
#define SAMC_NEEDQUESTIONNOTIFY_KEY         @"samc_needquestionnotify_key"
#define SAMC_NEEDSOUND_KEY                  @"samc_needsound_key"
#define SAMC_NEEDVIBRATE_KEY                @"samc_needvibrate_key"
#define SAMC_ADVRECALL_MINUTE_KEY           @"samc_advrecall_minute_key"

@interface SAMCPreferenceManager ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation SAMCPreferenceManager

@synthesize currentUserMode = _currentUserMode;
@synthesize loginData = _loginData;
@synthesize needQuestionNotify = _needQuestionNotify;
@synthesize needSound = _needSound;
@synthesize needVibrate = _needVibrate;
@synthesize advRecallTimeMinute = _advRecallTimeMinute;

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
        _loginData = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAMC_LOGINDATA_KEY];
        _needQuestionNotify = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needQuestionNotify forKey:SAMC_NEEDQUESTIONNOTIFY_KEY];
        _needSound = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needSound forKey:SAMC_NEEDSOUND_KEY];
        _needVibrate = @(YES);
        [[NSUserDefaults standardUserDefaults] setValue:_needVibrate forKey:SAMC_NEEDVIBRATE_KEY];
        _advRecallTimeMinute = @(2); // default to 2 minutes
        [[NSUserDefaults standardUserDefaults] setValue:_advRecallTimeMinute forKey:SAMC_ADVRECALL_MINUTE_KEY];
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

#pragma mark - loginData
- (SAMCLoginData *)loginData
{
    __block SAMCLoginData *loginData;
    dispatch_sync(_syncQueue, ^{
        if (_loginData == nil) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SAMC_LOGINDATA_KEY];
            if (data) {
                _loginData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        loginData = _loginData;
    });
    return loginData;
}

- (void)setLoginData:(SAMCLoginData *)loginData
{
    dispatch_barrier_async(_syncQueue, ^{
        _loginData = loginData;
        if (loginData) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:loginData];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:SAMC_LOGINDATA_KEY];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAMC_LOGINDATA_KEY];
        }
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

#pragma mark - advRecallTimeMinute
- (NSNumber *)advRecallTimeMinute
{
    __block NSNumber *minutes;
    dispatch_sync(_syncQueue, ^{
        if (_advRecallTimeMinute == nil) {
            _advRecallTimeMinute = [[NSUserDefaults standardUserDefaults] valueForKey:SAMC_ADVRECALL_MINUTE_KEY];
            _advRecallTimeMinute = _advRecallTimeMinute ?:@(2);
        }
        minutes = _advRecallTimeMinute;
    });
    return minutes;
}

- (void)setAdvRecallTimeMinute:(NSNumber *)advRecallTimeMinute
{
    dispatch_barrier_async(_syncQueue, ^{
        _advRecallTimeMinute = advRecallTimeMinute;
        [[NSUserDefaults standardUserDefaults] setValue:advRecallTimeMinute forKey:SAMC_ADVRECALL_MINUTE_KEY];
    });
}

@end
