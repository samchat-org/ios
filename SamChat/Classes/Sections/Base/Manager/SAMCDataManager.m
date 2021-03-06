//
//  SAMCDataManager.m
//  SamChat
//
//  Created by HJ on 9/6/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDataManager.h"
#import "NTESChatroomManager.h"
#import "NTESCustomAttachmentDefines.h"
#import "SAMCUser.h"
#import "SAMCUserManager.h"

@interface SAMCDataRequest : NSObject

@property (nonatomic,assign) NSInteger maxMergeCount; //最大合并数

- (void)requestUserIds:(NSArray *)userIds;

@end


@interface SAMCDataManager()<NIMUserManagerDelegate,NIMTeamManagerDelegate,SAMCUserManagerDelegate>

@property (nonatomic,strong) SAMCDataRequest *request;
@property (nonatomic,strong) UIImage *defaultUserAvatar;
@property (nonatomic,strong) UIImage *defaultTeamAvatar;

@end

@implementation SAMCDataManager

+ (instancetype)sharedManager
{
    static SAMCDataManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCDataManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _defaultUserAvatar = [UIImage imageNamed:@"avatar_user"];
        _defaultTeamAvatar = [UIImage imageNamed:@"avatar_team"];
        _request = [[SAMCDataRequest alloc] init];
        _request.maxMergeCount = 20;
        [[NIMSDK sharedSDK].userManager addDelegate:self];
        [[NIMSDK sharedSDK].teamManager addDelegate:self];
        [[SAMCUserManager sharedManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
    [[NIMSDK sharedSDK].teamManager removeDelegate:self];
    [[SAMCUserManager sharedManager] removeDelegate:self];
}

- (NIMKitInfo *)infoByUser:(NSString *)userId
                 inSession:(NIMSession *)session
{
    BOOL needFetchInfo = NO;
    NIMSessionType sessionType = session.sessionType;
    NIMKitInfo *info = [[NIMKitInfo alloc] init];
    info.infoId = userId;
    info.showName = userId; //默认值
    switch (sessionType) {
        case NIMSessionTypeP2P:
        case NIMSessionTypeTeam:
        {
            SAMCUser *user = [[SAMCUserManager sharedManager] userInfo:userId];
            SAMCUserInfo *userInfo = user.userInfo;
            if ([userInfo.username length] > 0) {
                info.showName = userInfo.username;
            }
            info.avatarUrlString = userInfo.avatar;
            info.avatarImage = self.defaultUserAvatar;
            info.serviceCategory = userInfo.spInfo.serviceCategory;
            
            if (userInfo == nil)
            {
                needFetchInfo = YES;
            }
        }
            break;
        case NIMSessionTypeChatroom:
            NSAssert(0, @"invalid type"); //聊天室的Info不会通过这个回调请求
            break;
        default:
            NSAssert(0, @"invalid type");
            break;
    }
    
    if (needFetchInfo)
    {
        [self.request requestUserIds:@[userId]];
    }
    return info;
}

- (NIMKitInfo *)infoByTeam:(NSString *)teamId
{
    NIMTeam *team    = [[NIMSDK sharedSDK].teamManager teamById:teamId];
    NIMKitInfo *info = [[NIMKitInfo alloc] init];
    info.showName    = team.teamName;
    info.infoId      = teamId;
    info.avatarImage = self.defaultTeamAvatar;
    info.avatarUrlString = team.thumbAvatarUrl;
    return info;
}

- (NIMKitInfo *)infoByUser:(NSString *)userId
               withMessage:(NIMMessage *)message
{
    if (message.session.sessionType == NIMSessionTypeChatroom)
    {
        NIMKitInfo *info = [[NIMKitInfo alloc] init];
        info.infoId = userId;
        if ([userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
            NIMChatroomMember *member = [[NTESChatroomManager sharedInstance] myInfo:message.session.sessionId];
            info.showName        = member.roomNickname;
            info.avatarUrlString = member.roomAvatar;
        }else{
            NIMMessageChatroomExtension *ext = [message.messageExt isKindOfClass:[NIMMessageChatroomExtension class]] ?
            (NIMMessageChatroomExtension *)message.messageExt : nil;
            info.showName = ext.roomNickname;
            info.avatarUrlString = ext.roomAvatar;
        }
        info.avatarImage = self.defaultUserAvatar;
        return info;
    }
    else
    {
        return [self infoByUser:userId
                      inSession:message.session];
    }
}

- (NSString *)tipMessage:(NIMMessage *)message
{
    NSString *text = nil;
    NIMMessageType type = message.messageType;
    if (type == NIMMessageTypeCustom) {
        NIMCustomObject *object = (NIMCustomObject *)message.messageObject;
        id<NTESCustomAttachmentInfo> attachment = (id<NTESCustomAttachmentInfo>)object.attachment;
        if ([attachment respondsToSelector:@selector(formatedMessage)]) {
            text =  [attachment formatedMessage];
        }
        
    }
    return text;
}


//将个人信息和群组信息变化通知给 NIMKit 。
//如果您的应用不托管个人信息给云信，则需要您自行在上层监听个人信息变动，并将变动通知给 NIMKit。
#pragma mark - NIMUserManagerDelegate
- (void)onUserInfoChanged:(id)user // SAMCUserManagerDelegate & NIMUserManagerDelegate
{
    if ([user isKindOfClass:[NIMUser class]]) {
        DDLogWarn(@"NIMUserManagerDelegate onUserInfoChanged:%@", user);
    }
    if ([user isKindOfClass:[SAMCUser class]]) {
        [[NIMKit sharedKit] notfiyUserInfoChanged:@[((SAMCUser *)user).userId]];
    }
}

- (void)onBlackListChanged{
    [[NIMKit sharedKit] notifyUserBlackListChanged];
}

- (void)onMuteListChanged
{
    [[NIMKit sharedKit] notifyUserMuteListChanged];
}


#pragma mark - NIMTeamManagerDelegate
- (void)onTeamAdded:(NIMTeam *)team
{
    [[NIMKit sharedKit] notfiyTeamInfoChanged:@[team.teamId]];
}

- (void)onTeamUpdated:(NIMTeam *)team
{
    [[NIMKit sharedKit] notfiyTeamInfoChanged:@[team.teamId]];
}

- (void)onTeamRemoved:(NIMTeam *)team
{
    [[NIMKit sharedKit] notfiyTeamInfoChanged:@[team.teamId]];
}

- (void)onTeamMemberChanged:(NIMTeam *)team
{
    [[NIMKit sharedKit] notfiyTeamMemebersChanged:@[team.teamId]];
}

@end


@implementation SAMCDataRequest{
    NSMutableArray *_requstUserIdArray; //待请求池
    BOOL _isRequesting;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _requstUserIdArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)requestUserIds:(NSArray *)userIds
{
    for (NSString *userId in userIds)
    {
        if (![_requstUserIdArray containsObject:userId])
        {
            [_requstUserIdArray addObject:userId];
            DDLogInfo(@"should request info for userid %@",userId);
        }
    }
    [self request];
}


- (void)request
{
    static NSUInteger MaxBatchReuqestCount = 10;
    if (_isRequesting || [_requstUserIdArray count] == 0) {
        return;
    }
    _isRequesting = YES;
    NSArray *userIds = [_requstUserIdArray count] > MaxBatchReuqestCount ?
    [_requstUserIdArray subarrayWithRange:NSMakeRange(0, MaxBatchReuqestCount)] : [_requstUserIdArray copy];
    
    DDLogInfo(@"request user ids %@",userIds);
    __weak typeof(self) weakSelf = self;
    [[SAMCUserManager sharedManager] fetchUserInfos:userIds completion:^(NSArray<SAMCUser *> * _Nullable users, NSError * _Nullable error) {
        [weakSelf afterReuquest:userIds];
        if (!error) {
            [[NIMKit sharedKit] notfiyUserInfoChanged:userIds];
        }
    }];
}

- (void)afterReuquest:(NSArray *)userIds
{
    _isRequesting = NO;
    [_requstUserIdArray removeObjectsInArray:userIds];
    [self request];
    
}

@end