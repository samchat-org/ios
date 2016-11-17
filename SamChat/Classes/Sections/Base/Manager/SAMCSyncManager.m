//
//  SAMCSyncManager.m
//  SamChat
//
//  Created by HJ on 9/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSyncManager.h"
#import "Reachability.h"
#import "SAMCStateDateInfo.h"
#import "AFNetworking.h"
#import "SAMCDataPostSerializer.h"
#import "SAMCServerAPI.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCDataBaseManager.h"

typedef void (^SyncAction)();

@interface SAMCSyncManager ()

@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic, strong) SAMCStateDateInfo *stateDateInfo;
@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, assign) BOOL stoped;
@property (nonatomic, copy) SyncAction syncBlock;
@property (nonatomic, assign) NSTimeInterval retryDelay;

@end

@implementation SAMCSyncManager

+ (instancetype)sharedManager
{
    static SAMCSyncManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCSyncManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _retryDelay = 20.0;
    }
    return self;
}

- (void)dealloc
{
}

- (void)start
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification object:nil];
    self.syncBlock = [self queryStateDateBlock];
    self.isSyncing = NO;
    self.stoped = NO;
    [self doSync];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
}

- (void)close
{
    [self.internetReachability stopNotifier];
    self.internetReachability = nil;
    self.stoped = YES;
    _syncBlock = NULL;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doSync
{
    if (_isSyncing) {
        return;
    }
    if (_stoped) {
        return;
    }
    _isSyncing = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (_syncBlock) {
        if (![[Reachability reachabilityForInternetConnection] isReachable]) {
            self.isSyncing = NO;
            [self performSelector:@selector(doSync) withObject:nil afterDelay:self.retryDelay];
        } else {
            _syncBlock();
        }
    } else {
        [self close];
    }
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    if (curReach != self.internetReachability) {
        return;
    }
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired = [curReach connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable: {
            statusString = @"Access Not Available";
            //connectionRequired may return YES even when the host is unreachable.
            connectionRequired = NO;
            break;
        }
        case ReachableViaWWAN: {
            statusString = @"Reachable WWAN";
            break;
        }
        case ReachableViaWiFi: {
            statusString= @"Reachable WiFi";
            break;
        }
    }
    
    if (connectionRequired) {
        NSString *connectionRequiredFormatString = @"%@, Connection Required";
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    } else {
        [self doSync];
    }
    DDLogDebug(@"reachability: %@", statusString);
}

#pragma mark - Sync blocks
- (SyncAction)queryStateDateBlock
{
    __weak typeof(self) wself = self;
    return ^(){
        DDLogDebug(@"queryStateDateBlock start");
        [wself queryStateDateCompletion:^(SAMCStateDateInfo *stateDateInfo, NSError *error) {
            if (error) {
                wself.isSyncing = NO;
                [wself performSelector:@selector(doSync) withObject:nil afterDelay:wself.retryDelay];
            } else {
                wself.stateDateInfo = stateDateInfo;
                wself.syncBlock = [wself queryServicerListBlock];
                wself.isSyncing = NO;
                [wself doSync];
            }
        }];
    };
}

- (SyncAction)queryServicerListBlock
{
    __weak typeof(self) wself = self;
    return ^(){
        NSString *localServicerListVersion = wself.localServicerListVersion;
        if ([wself.stateDateInfo.servicerListVersion isEqualToString:localServicerListVersion]) {
            DDLogDebug(@"queryServicerListBlock no need to sync servicer list");
            wself.syncBlock = [wself queryCustomerListBlock];
            wself.isSyncing = NO;
            [wself doSync];
            return;
        }
        [wself queryContactList:SAMCContactListTypeServicer completion:^(NSError *error) {
            if (error) {
                DDLogDebug(@"queryServicerListBlock sync servicer list error: %@", error);
                wself.isSyncing = NO;
                [wself performSelector:@selector(doSync) withObject:nil afterDelay:wself.retryDelay];
            } else {
                DDLogDebug(@"queryServicerListBlock sync servicer list finished");
                [wself updateLocalContactListVersion:wself.stateDateInfo.servicerListVersion type:SAMCContactListTypeServicer];
                wself.syncBlock = [wself queryCustomerListBlock];
                wself.isSyncing = NO;
                [wself doSync];
            }
        }];
    };
}

- (SyncAction)queryCustomerListBlock
{
    __weak typeof(self) wself = self;
    return ^(){
        NSString *localCustomerListVersion = wself.localCustomerListVersion;
        if ([wself.stateDateInfo.customerListVersion isEqualToString:localCustomerListVersion]) {
            DDLogDebug(@"queryCustomerListBlock no need to sync customer list");
            wself.syncBlock = [wself queryFollowListBlock];
            wself.isSyncing = NO;
            [wself doSync];
            return;
        }
        [wself queryContactList:SAMCContactListTypeCustomer completion:^(NSError *error) {
            if (error) {
                DDLogDebug(@"queryCustomerListBlock sync customer list error: %@", error);
                wself.isSyncing = NO;
                [wself performSelector:@selector(doSync) withObject:nil afterDelay:wself.retryDelay];
            } else {
                DDLogDebug(@"queryCustomerListBlock sync customer list finished");
                [wself updateLocalContactListVersion:wself.stateDateInfo.customerListVersion type:SAMCContactListTypeCustomer];
                wself.syncBlock = [wself queryFollowListBlock];
                wself.isSyncing = NO;
                [wself doSync];
            }
        }];
    };
}

- (SyncAction)queryFollowListBlock
{
    __weak typeof(self) wself = self;
    return ^(){
        NSString *localFollowListVersion = wself.localFollowListVersion;
        if ([wself.stateDateInfo.followListVersion isEqualToString:localFollowListVersion]) {
            DDLogDebug(@"queryFollowListBlock no need to sync follow list");
            wself.syncBlock = NULL;
            wself.isSyncing = NO;
            [wself doSync];
            return;
        }
        [wself queryFollowListCompletion:^(NSError *error) {
            if (error) {
                DDLogDebug(@"queryFollowListBlock sync error: %@", error);
                wself.isSyncing = NO;
                [wself performSelector:@selector(doSync) withObject:nil afterDelay:wself.retryDelay];
            } else {
                DDLogDebug(@"queryFollowListBlock sync finished");
                [wself updateLocalFollowListVersion:wself.stateDateInfo.followListVersion];
                wself.syncBlock = NULL;
                wself.isSyncing = NO;
                [wself doSync];
            }
        }];
    };
}

#pragma mark - Server
- (void)queryStateDateCompletion:(void(^)(SAMCStateDateInfo *stateDateInfo, NSError *error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryStateDate];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_PROFILE_QUERY_STATE_DATE parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogDebug(@"queryStateDate Response:%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject;
            NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
            if (errorCode) {
                completion(nil, [SAMCServerErrorHelper errorWithCode:errorCode]);
            } else {
                SAMCStateDateInfo *info = [SAMCStateDateInfo stateDateInfoFromDict:response[SAMC_STATE_DATE_INFO]];
                completion(info, nil);
            }
        } else {
            completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorUnknowError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"queryStateDate Error:%@", error);
        completion(nil, [SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)queryContactList:(SAMCContactListType)type completion:(void(^)(NSError *error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryContactList:type];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_CONTACT_CONTACT_LIST_QUERY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL result = NO;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *response = responseObject;
                NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
                if (errorCode == 0) {
                    NSArray *users = response[SAMC_USERS];
                    result = [[SAMCDataBaseManager sharedManager].userInfoDB updateContactList:users type:type];
                }
            }
            NSError *aError = nil;
            if (result == NO) {
                aError = [SAMCServerErrorHelper errorWithCode:SAMCServerErrorSyncFailed];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(aError);
            });
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

- (void)queryFollowListCompletion:(void(^)(NSError *error))completion
{
    NSAssert(completion != nil, @"completion block should not be nil");
    NSDictionary *parameters = [SAMCServerAPI queryFollowList];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [SAMCDataPostSerializer serializer];
    [manager POST:SAMC_URL_OFFICIALACCOUNT_FOLLOW_LIST_QUERY parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL result = NO;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *response = responseObject;
                NSInteger errorCode = [((NSNumber *)response[SAMC_RET]) integerValue];
                if (errorCode == 0) {
                    NSArray *users = response[SAMC_USERS];
                    if ((users != nil) && ([users isKindOfClass:[NSArray class]])) {
                        result = [[SAMCDataBaseManager sharedManager].publicDB updateFollowList:users];
                    }
                }
            }
            NSError *aError = nil;
            if (result == NO) {
                aError = [SAMCServerErrorHelper errorWithCode:SAMCServerErrorSyncFailed];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(aError);
            });
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion([SAMCServerErrorHelper errorWithCode:SAMCServerErrorServerNotReachable]);
    }];
}

#pragma mark -
- (void)updateLocalContactListVersionFrom:(NSString *)fromVersion
                                       to:(NSString *)toVersion
                                     type:(SAMCContactListType)listType
{
    if (listType == SAMCContactListTypeServicer) {
        if ([fromVersion isEqualToString:self.localServicerListVersion]) {
            [self updateLocalContactListVersion:toVersion type:listType];
            DDLogDebug(@"update servicer list version from %@ to %@", fromVersion, toVersion);
        }
    } else {
        if ([fromVersion isEqualToString:self.localCustomerListVersion]) {
            [self updateLocalContactListVersion:toVersion type:listType];
            DDLogDebug(@"update customer list version from %@ to %@", fromVersion, toVersion);
        }
    }
}

- (void)updateLocalFollowListVersionFrom:(NSString *)fromVersion
                                      to:(NSString *)toVersion
{
    if ([fromVersion isEqualToString:self.localFollowListVersion]) {
        [self updateLocalFollowListVersion:toVersion];
    }
}

- (void)updateLocalContactListVersion:(NSString *)version type:(SAMCContactListType)listType
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [[SAMCDataBaseManager sharedManager].userInfoDB updateLocalContactListVersion:version
                                                                                type:listType];
    });
}

- (void)updateLocalFollowListVersion:(NSString *)version
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SAMCDataBaseManager sharedManager].publicDB updateFollowListVersion:version];
    });
}

#pragma mark - private
- (NSString *)localServicerListVersion
{
    return [[SAMCDataBaseManager sharedManager].userInfoDB localContactListVersionOfType:SAMCContactListTypeServicer];
}

- (NSString *)localCustomerListVersion
{
    return [[SAMCDataBaseManager sharedManager].userInfoDB localContactListVersionOfType:SAMCContactListTypeCustomer];
}

- (NSString *)localFollowListVersion
{
    return [[SAMCDataBaseManager sharedManager].publicDB localFollowListVersion];
}

@end
