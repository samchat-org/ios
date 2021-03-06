//
//  SAMCNIMSessionViewController.m
//  SamChat
//
//  Created by HJ on 8/5/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCNIMSessionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NIMInputView.h"
#import "NIMInputTextView.h"
#import "UIView+NIM.h"
#import "NIMMessageCellProtocol.h"
#import "NIMMessageModel.h"
#import "NIMKitUtil.h"
#import "NIMCustomLeftBarView.h"
#import "NIMBadgeView.h"
#import "UITableView+NIMScrollToBottom.h"
#import "NIMMessageMaker.h"
#import "NIMDefaultValueMaker.h"
#import "NIMTimestampModel.h"
#import "NIMMessageCellMaker.h"
#import "NIMUIConfig.h"
#import "NIMKit.h"
#import "SAMCPreferenceManager.h"
#import "SAMCChatManager.h"
#import "SAMCConversationManager.h"

static const void * const SAMCDispatchMessageDataPrepareSpecificKey = &SAMCDispatchMessageDataPrepareSpecificKey;
dispatch_queue_t SAMCMessageDataPrepareQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("nim.demo.message.queue", 0);
        dispatch_queue_set_specific(queue, SAMCDispatchMessageDataPrepareSpecificKey, (void *)SAMCDispatchMessageDataPrepareSpecificKey, NULL);
    });
    return queue;
}

@interface SAMCNIMSessionViewController ()
<
NIMTeamManagerDelegate,
NIMMediaManagerDelgate,
NIMMessageCellDelegate,
NIMUserManagerDelegate>

@property (nonatomic,strong,readwrite) UITableView *tableView;

@property (nonatomic,strong) NIMSessionMsgDatasource *sessionDatasource;
@property (nonatomic,strong) NSMutableArray *pendingMessages;   //缓存的插入消息,聊天室需要在另外个线程计算高度,减少UI刷新
@property (nonatomic,readwrite)   NIMMessage *messageForMenu;
@property (nonatomic,strong) NSIndexPath *lastVisibleIndexPathBeforeRotation;

@end

@implementation SAMCNIMSessionViewController

- (instancetype)initWithSession:(SAMCSession *)session{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _samcSession = session;
        _pendingMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
    [self makeHandlerAndDataSource];
}


-(void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
//    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[SAMCChatManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)makeUI
{
    self.navigationItem.title = [self sessionTitle];
//    NIMCustomLeftBarView *leftBarView = [[NIMCustomLeftBarView alloc] init];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarView];
//    self.navigationItem.leftBarButtonItem = leftItem;
//    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = NIMKit_UIColorFromRGB(0xECEDF0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.tableView addSubview:_refreshControl];
    [self.refreshControl addTarget:self action:@selector(headerRereshing:) forControlEvents:UIControlEventValueChanged];
    
    CGRect inputViewRect = CGRectMake(0, 0, self.view.nim_width, [NIMUIConfig topInputViewHeight]);
    BOOL disableInputView = NO;
    if ([self.sessionConfig respondsToSelector:@selector(disableInputView)]) {
        disableInputView = [self.sessionConfig disableInputView];
    }
    if (!disableInputView) {
        _sessionInputView = [[NIMInputView alloc] initWithFrame:inputViewRect];
        _sessionInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.sessionInputView.nim_bottom = self.view.nim_height;
        [self.sessionInputView setInputConfig:[self sessionConfig]];
        [self.sessionInputView setInputActionDelegate:self];
        [self.view addSubview:self.sessionInputView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vcBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)makeHandlerAndDataSource
{
    _layoutManager = [[NIMSessionViewLayoutManager alloc] initWithInputView:self.sessionInputView tableView:self.tableView];
    
    //数据
    id<NIMKitMessageProvider> dataProvider = [self.sessionConfig respondsToSelector:@selector(messageDataProvider)] ? [self.sessionConfig messageDataProvider] : nil;
    NSInteger limit = [NIMUIConfig messageLimit];
    if ([self.sessionConfig respondsToSelector:@selector(messageLimit)]) {
        limit = self.sessionConfig.messageLimit;
    }
    NSTimeInterval showTimestampInterval = [NIMUIConfig messageTimeInterval];
    if ([self.sessionConfig respondsToSelector:@selector(showTimeInterval)]) {
        showTimestampInterval = [self.sessionConfig showTimestampInterval];
    }
    _sessionDatasource = [[NIMSessionMsgDatasource alloc] initWithSession:[_samcSession nimSession]
                                                                   spMode:(_samcSession.sessionMode==SAMCUserModeTypeSP)
                                                             dataProvider:dataProvider
                                                         showTimeInterval:showTimestampInterval
                                                                    limit:limit];
    _sessionDatasource.sessionConfig = [self sessionConfig];
    [self.conversationManager markAllMessagesReadInSession:_samcSession];
    
    _sessionDatasource.delegate = self;
    
    if (![self.sessionConfig respondsToSelector:@selector(autoFetchWhenOpenSession)] || self.sessionConfig.autoFetchWhenOpenSession) {
        [_sessionDatasource resetMessages:nil];
    }
    
    
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    for (id model in _sessionDatasource.modelArray) {
        if ([model isKindOfClass:[NIMMessageModel class]])
        {
            [messageArray addObject:[model message]];
        }
    }
    [self checkAttachmentState:messageArray];
    [self sendMessageReceipt:messageArray];
    
//    [[[NIMSDK sharedSDK] chatManager] addDelegate:self];
    [[SAMCChatManager sharedManager] addDelegate:self];
    
    if (_samcSession.sessionType == NIMSessionTypeTeam) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamInfoHasUpdatedNotification:) name:NIMKitTeamInfoHasUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamMembersHasUpdatedNotification:) name:NIMKitTeamMembersHasUpdatedNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoHasUpdatedNotification:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //fix bug: 竖屏进入会话界面，然后右上角进入群信息，再横屏，左上角返回，横屏的会话界面显示的就是竖屏时的大小
    [self.sessionDatasource cleanCache];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_sessionInputView endEditing:YES];
}


- (void)viewDidLayoutSubviews{
    BOOL isFirstLayout = CGRectEqualToRect(_layoutManager.viewRect, CGRectZero);
    if (isFirstLayout) {
        [self.tableView nim_scrollToBottom:NO];
    }
    [_layoutManager setViewRect:self.view.frame];
}

- (void)checkAttachmentState:(NSArray *)messages{
    for (NIMMessage *message in messages) {
        if (message.attachmentDownloadState == NIMMessageAttachmentDownloadStateNeedDownload) {
            [[NIMSDK sharedSDK].chatManager fetchMessageAttachment:message error:nil];
        }
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionDatasource.modelArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    id model = [[_sessionDatasource modelArray] objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[NIMMessageModel class]]) {
        cell = [NIMMessageCellMaker cellInTable:tableView
                                 forMessageMode:model];
        [(NIMMessageCell *)cell setMessageDelegate:self];
    }
    else if ([model isKindOfClass:[NIMTimestampModel class]])
    {
        cell = [NIMMessageCellMaker cellInTable:tableView
                                   forTimeModel:model];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    id modelInArray = [[_sessionDatasource modelArray] objectAtIndex:indexPath.row];
    if ([modelInArray isKindOfClass:[NIMMessageModel class]])
    {
        NIMMessageModel *model = (NIMMessageModel *)modelInArray;
        NSAssert([model respondsToSelector:@selector(contentSize)], @"config must have a cell height value!!!");
        [self layoutConfig:model];
        CGSize size = model.contentSize;
        UIEdgeInsets contentViewInsets = model.contentViewInsets;
        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom;
    }
    else if ([modelInArray isKindOfClass:[NIMTimestampModel class]])
    {
        cellHeight = [modelInArray height];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

#pragma mark - 消息收发接口
- (void)sendMessage:(NIMMessage *)message
{
    NIMMessageSetting *setting = message.setting ?:[[NIMMessageSetting alloc] init];
    setting.roamingEnabled = false;
    message.setting = setting;
    if (_samcSession.sessionType != NIMSessionTypeP2P) {
        [[[NIMSDK sharedSDK] chatManager] sendMessage:message toSession:[_samcSession nimSession] error:nil];
        return;
    }
    id usermodeValue = nil;
    if (_samcSession.sessionMode == SAMCUserModeTypeSP) {
        usermodeValue = MESSAGE_EXT_FROM_USER_MODE_VALUE_SP;
    } else {
        usermodeValue = MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM;
    }
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:message.remoteExt];
    [ext addEntriesFromDictionary:@{MESSAGE_EXT_FROM_USER_MODE_KEY:usermodeValue}];
    if (self.questionId) {
        [ext setObject:[self.questionId stringValue] forKey:MESSAGE_EXT_QUESTION_ID_KEY];
    }
    if (self.publicMessageId) {
        [ext setObject:[self.publicMessageId stringValue] forKey:MESSAGE_EXT_PUBLIC_ID_KEY];
    }
    message.remoteExt = ext;
    
    SAMCMessage *samcmessage = [SAMCMessage message:message.messageId session:_samcSession];
    samcmessage.nimMessage = message;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // TODO: need check here, should insert message after sendMessage ok?
        [[SAMCConversationManager sharedManager] insertMessages:@[samcmessage] unreadCount:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[NIMSDK sharedSDK] chatManager] sendMessage:message toSession:[_samcSession nimSession] error:nil];
        });
    });
}

#pragma mark - SAMCChatManagerDelegate
//发送消息
- (void)willSendMessage:(NIMMessage *)message
{
    if ([self isCurrentModeMessage:message] && [message.session isEqual:[_samcSession nimSession]]) {
        if ([self findModel:message]) {
            [self uiUpdateMessage:message];
        }else{
            [self uiAddMessages:@[message]];
        }
    }
}

//发送结果
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([self isCurrentModeMessage:message] && [message.session isEqual:[_samcSession nimSession]]) {
        NIMMessageModel *model = [self makeModel:message];
        NSInteger index = [self.sessionDatasource indexAtModelArray:model];
        [self.layoutManager updateCellAtIndex:index model:model];
        if (error == nil) {
            id ext = message.remoteExt;
            // 如果发送的消息带有questionId，则发送成功的时候更新这个消息的status
            NSString *questionIdStr = [ext valueForKey:MESSAGE_EXT_QUESTION_ID_KEY];
            if ((questionIdStr != nil) && [self.questionId isEqual:@([questionIdStr intValue])]) {
                self.questionId = nil;
            }
            // 如果发送的消息带有publicMessageId，则发送成功的时候更新这个消息的status
            NSString *publicMessageIdStr = [ext valueForKey:MESSAGE_EXT_PUBLIC_ID_KEY];
            if ((publicMessageIdStr != nil) && [self.publicMessageId isEqual:@([publicMessageIdStr intValue])]) {
                self.publicMessageId = nil;
            }
        }
    }
}

//发送进度
-(void)sendMessage:(NIMMessage *)message progress:(CGFloat)progress
{
    if ([self isCurrentModeMessage:message] && [message.session isEqual:[_samcSession nimSession]]) {
        NIMMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDatasource indexAtModelArray:model] model:model];
    }
}

//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    NIMMessage *nimmessage = messages.firstObject;
    NIMSession *nimsession = nimmessage.session;
    if (![nimsession.sessionId isEqual:_samcSession.sessionId] || !messages.count){
        return;
    }
    
    if (nimsession.sessionType == NIMSessionTypeChatroom) {
        [self uiAddChatroomMessages:messages];
    }
    else{
        [self uiAddMessages:messages];
        [self.conversationManager markAllMessagesReadInSession:_samcSession];
    }
    
    [self sendMessageReceipt:messages];
}


- (void)fetchMessageAttachment:(NIMMessage *)message progress:(CGFloat)progress
{
    if ([self isCurrentModeMessage:message] && [message.session isEqual:[_samcSession nimSession]]) {
        NIMMessageModel *model = [self makeModel:message];
        [_layoutManager updateCellAtIndex:[self.sessionDatasource indexAtModelArray:model] model:model];
    }
}

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([self isCurrentModeMessage:message] && [message.session isEqual:[_samcSession nimSession]]) {
        NIMMessageModel *model = [self makeModel:message];
        //下完缩略图之后，因为比例有变化，重新刷下宽高。
        [model calculateContent:self.tableView.nim_width force:YES];
        [_layoutManager updateCellAtIndex:[self.sessionDatasource indexAtModelArray:model] model:model];
    }
}

- (void)onRecvMessageReceipt:(NIMMessageReceipt *)receipt
{
    if ([receipt.session isEqual:[_samcSession nimSession]]) {
        [self checkReceipt];
    }
}

#pragma mark - Notification
- (void)onUserInfoHasUpdatedNotification:(NSNotification *)notification {
    self.navigationItem.title = [self sessionTitle];
    [self.tableView reloadData];
}

- (void)onTeamMembersHasUpdatedNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSArray *teamIds = userInfo[NIMKitInfoKey];
    if (_samcSession.sessionType == NIMSessionTypeTeam
        && [teamIds containsObject:_samcSession.sessionId]) {
        [self.tableView reloadData];
        self.navigationItem.title = [self sessionTitle];
    }
}

- (void)onTeamInfoHasUpdatedNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSArray *teamIds = userInfo[NIMKitInfoKey];
    if (_samcSession.sessionType == NIMSessionTypeTeam
        && [teamIds containsObject:_samcSession.sessionId]) {
        self.navigationItem.title = [self sessionTitle];
    }
}


#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_sessionInputView endEditing:YES];
}

#pragma marlk - 通知
- (void)messageDataIsReady{
    
    if ([self shouldHandleReceipt]) {
        [self.sessionDatasource checkReceipt];
    }
    
    [self.tableView reloadData];
    [self.tableView nim_scrollToBottom:NO];
}


#pragma mark - 会话title
- (NSString *)sessionTitle
{
    NSString *title = @"";
    NIMSessionType type = _samcSession.sessionType;
    switch (type) {
        case NIMSessionTypeTeam:{
            NIMTeam *team = [[[NIMSDK sharedSDK] teamManager] teamById:_samcSession.sessionId];
            title = [NSString stringWithFormat:@"%@(%zd)",[team teamName],[team memberNumber]];
        }
            break;
        case NIMSessionTypeP2P:{
            title = [NIMKitUtil showNick:_samcSession.sessionId inSession:[_samcSession nimSession]];
        }
            break;
        default:
            break;
    }
    return title;
}

#pragma mark - NIMMediaManagerDelegate
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if (!filePath || error) {
        _sessionInputView.recording = NO;
        [self onRecordFailed:error];
    }
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error {
    if(!error) {
        if ([self recordFileCanBeSend:filePath]) {
            [self sendMessage:[NIMMessageMaker msgWithAudio:filePath]];
        }else{
            [self showRecordFileNotSendReason];
        }
    } else {
        [self onRecordFailed:error];
    }
    _sessionInputView.recording = NO;
}

- (void)recordAudioDidCancelled {
    _sessionInputView.recording = NO;
}

- (void)recordAudioProgress:(NSTimeInterval)currentTime {
    [_sessionInputView updateAudioRecordTime:currentTime];
}

- (void)recordAudioInterruptionBegin {
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

#pragma mark - 录音相关接口
- (void)onRecordFailed:(NSError *)error{}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    return YES;
}

- (void)showRecordFileNotSendReason{}


#pragma mark - NIMInputActionDelegate
- (void)onTapMediaItem:(NIMMediaItem *)item{}

- (void)onTextChanged:(id)sender{}

- (void)onSendText:(NSString *)text
{
    NIMMessage *message = [NIMMessageMaker msgWithText:text];
    [self sendMessage:message];
}

- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId{}

- (void)onCancelRecording
{
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

- (void)onStopRecording
{
    [[NIMSDK sharedSDK].mediaManager stopRecord];
}

- (void)onStartRecording
{
    _sessionInputView.recording = YES;
    
    NIMAudioType type = NIMAudioTypeAAC;
    if ([self.sessionConfig respondsToSelector:@selector(recordType)])
    {
        type = [self.sessionConfig recordType];
    }
    
    NSTimeInterval duration = 60.f;
    if ([self.sessionConfig respondsToSelector:@selector(maxRecordDuration)])
    {
        duration = [self.sessionConfig maxRecordDuration];
    }
    
    [[[NIMSDK sharedSDK] mediaManager] record:type
                                     duration:duration
                                     delegate:self];
}

#pragma mark - CellActionDelegate
- (void)onTapCell:(NIMKitEvent *)message{}

- (void)onRetryMessage:(NIMMessage *)message
{
    if (message.isReceivedMsg) {
        [[[NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message
                                                           error:nil];
    }else{
        [[[NIMSDK sharedSDK] chatManager] resendMessage:message
                                                  error:nil];
    }
}

- (void)onLongPressCell:(NIMMessage *)message
                 inView:(UIView *)view
{
    NSArray *items = [self menusItems:message];
    if ([items count] && [self becomeFirstResponder]) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        _messageForMenu = message;
        [controller setTargetRect:view.bounds inView:view];
        [controller setMenuVisible:YES animated:YES];
        
    }
}

#pragma mark - 配置项
- (id<NIMSessionConfig>)sessionConfig
{
    return nil;
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    
    if (message.messageType == NIMMessageTypeText) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyText:)]];
    }
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                action:@selector(deleteMsg:)]];
    return items;
    
}

- (NIMMessage *)messageForMenu
{
    return _messageForMenu;
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *items = [[UIMenuController sharedMenuController] menuItems];
    for (UIMenuItem *item in items) {
        if (action == [item action]){
            return YES;
        }
    }
    return NO;
}


- (void)copyText:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    if (message.text.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:message.text];
    }
}

- (void)deleteMsg:(id)sender
{
    NIMMessage *message    = [self messageForMenu];
    [self uiDeleteMessage:message];
    SAMCMessage *samcmessage = [SAMCMessage message:message.messageId
                                            session:_samcSession];
    samcmessage.nimMessage = message;
    [self.conversationManager deleteMessage:samcmessage];
}

- (void)menuDidHide:(NSNotification *)notification
{
    [UIMenuController sharedMenuController].menuItems = nil;
}


#pragma mark - 操作接口
- (void)uiAddMessages:(NSArray *)messages
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NIMMessage *message in messages)
    {
        if (![self isCurrentModeMessage:message]) {
            continue;
        }
        NIMMessageModel *model = [[NIMMessageModel alloc] initWithMessage:message spMode:(_samcSession.sessionMode==SAMCUserModeTypeSP)];
        [self layoutConfig:model];
        [models addObject:model];
    }
    NSArray *insert = [self.sessionDatasource addMessageModels:models];
    [self.tableView beginUpdates];
    [self.layoutManager insertTableViewCellAtRows:insert animated:YES];
    [self.tableView endUpdates];
}

- (void)uiAddChatroomMessages:(NSArray *)messages
{
    dispatch_async(SAMCMessageDataPrepareQueue(), ^{
        //后台线程处理宽度计算，处理完之后同步抛到主线程插入
        BOOL noPendingMessage = self.pendingMessages.count == 0;
        [self.pendingMessages addObjectsFromArray:messages];
        if (noPendingMessage)
        {
            [self processPendingMessages];
        }
    });
}

- (void)uiDeleteMessage:(NIMMessage *)message{
    NIMMessageModel *model = [self findModel:message];
    BOOL receipteRelated = model.shouldShowReadLabel;
    
    NSArray *indexs = [self.sessionDatasource deleteMessageModel:model];
    [self.tableView beginUpdates];
    [self.layoutManager deleteCellAtIndexs:indexs];
    [self.tableView endUpdates];
    
    if (receipteRelated)
    {
        [self checkReceipt];
    }
}

- (void)uiUpdateMessage:(NIMMessage *)message{
    NIMMessageModel *model = [self findModel:message];
    NSInteger index = [self.sessionDatasource indexAtModelArray:model];
    [self.sessionDatasource.modelArray replaceObjectAtIndex:index withObject:model];
    [self.layoutManager updateCellAtIndex:index model:model];
}

- (void)uiCheckReceipt
{
    [self checkReceipt];
}

#pragma mark - 旋转处理 (iOS7)
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return self.interfaceOrientation;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    
    self.lastVisibleIndexPathBeforeRotation = [self.tableView indexPathsForVisibleRows].lastObject;
    [self.sessionDatasource cleanCache];
    if (self.view.window) {
        [self.sessionInputView endEditing:YES];
        [[NIMSDK sharedSDK].mediaManager cancelRecord];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:self.lastVisibleIndexPathBeforeRotation atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - 旋转处理 (iOS8 or above)
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.lastVisibleIndexPathBeforeRotation = [self.tableView indexPathsForVisibleRows].lastObject;
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.view.window) {
        __weak typeof(self) wself = self;
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
         {
             [[NIMSDK sharedSDK].mediaManager cancelRecord];
             [wself.sessionDatasource cleanCache];
             [wself.tableView reloadData];
             [wself.tableView scrollToRowAtIndexPath:wself.lastVisibleIndexPathBeforeRotation atScrollPosition:UITableViewScrollPositionBottom animated:NO];
         } completion:nil];
    }
}

#pragma mark - 已读回执
- (BOOL)shouldHandleReceipt
{
    return _samcSession.sessionType == NIMSessionTypeP2P &&
    [self.sessionConfig respondsToSelector:@selector(shouldHandleReceipt)] &&
    [self.sessionConfig shouldHandleReceipt];
}


- (void)sendMessageReceipt:(NSArray *)messages
{
    if ([self shouldHandleReceipt])
    {
        //只有在当前 Application 是激活的状态下才发送已读回执
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            //找到最后一个需要发送已读回执的消息标记为已读
            for (NSInteger i = [messages count] - 1; i >= 0; i--) {
                id item = [messages objectAtIndex:i];
                NIMMessage *message = nil;
                if ([item isKindOfClass:[NIMMessage class]])
                {
                    message = item;
                }
                else if ([item isKindOfClass:[NIMMessageModel class]])
                {
                    message = [(NIMMessageModel *)item message];
                }
                if (message)
                {
                    if (!message.isOutgoingMsg &&
                        self.sessionConfig &&
                        [self.sessionConfig respondsToSelector:@selector(shouldHandleReceiptForMessage:)] &&
                        [self.sessionConfig shouldHandleReceiptForMessage:message])
                    {
                        
                        NIMMessageReceipt *receipt = [[NIMMessageReceipt alloc] initWithMessage:message];
                        
                        [[[NIMSDK sharedSDK] chatManager] sendMessageReceipt:receipt
                                                                  completion:nil];  //忽略错误,如果失败下次再发即可
                        return;
                    }
                }
            }
        }
    }
}

- (void)vcBecomeActive:(NSNotification *)notification
{
    if ([self shouldHandleReceipt])
    {
        NSArray *models = [self.sessionDatasource modelArray];
        [self sendMessageReceipt:models];
    }
}


#pragma mark - Private
- (id<NIMCellLayoutConfig>)layoutConfigForModel:(NIMMessageModel *)model
{
    id<NIMCellLayoutConfig> config = nil;
    if ([self.sessionConfig respondsToSelector:@selector(layoutConfigWithMessage:)]) {
        config = [self.sessionConfig layoutConfigWithMessage:model.message];
    }
    return config ? : [[NIMDefaultValueMaker sharedMaker] cellLayoutDefaultConfig];
}

- (void)layoutConfig:(NIMMessageModel *)model{
    
    model.sessionConfig = self.sessionConfig;
    model.layoutConfig = [self layoutConfigForModel:model];
    [model calculateContent:self.tableView.nim_width force:NO];
}


- (NIMMessageModel *)makeModel:(NIMMessage *)message{
    NIMMessageModel *model = [self findModel:message];
    if (!model) {
        model = [[NIMMessageModel alloc] initWithMessage:message spMode:(_samcSession.sessionMode==SAMCUserModeTypeSP)];
    }
    [self layoutConfig:model];
    return model;
}

- (NIMMessageModel *)findModel:(NIMMessage *)message{
    NIMMessageModel *model;
    for (NIMMessageModel *item in self.sessionDatasource.modelArray.reverseObjectEnumerator.allObjects) {
        if ([item isKindOfClass:[NIMMessageModel class]] && [item.message isEqual:message]) {
            model = item;
            //防止那种进了会话又退出去再进来这种行为，防止SDK里回调上来的message和会话持有的message不是一个，导致刷界面刷跪了的情况
            model.message = message;
        }
    }
    return model;
}


- (void)headerRereshing:(id)sender
{
    __weak NIMSessionViewLayoutManager *layoutManager = self.layoutManager;
    __weak typeof(self) wself = self;
    __weak UIRefreshControl *refreshControl = self.refreshControl;
    [self.sessionDatasource loadHistoryMessagesWithComplete:^(NSInteger index,NSArray *memssages, NSError *error) {
        [refreshControl endRefreshing];
        if (memssages.count) {
            [layoutManager reloadData];
            [wself checkAttachmentState:memssages];
            [wself checkReceipt];
        }
    }];
}

- (SAMCConversationManager *)conversationManager{
    switch (_samcSession.sessionType) {
        case NIMSessionTypeChatroom:
            return nil;
            break;
        case NIMSessionTypeP2P:
        case NIMSessionTypeTeam:
        default:
//            return [NIMSDK sharedSDK].conversationManager;
            return [SAMCConversationManager sharedManager];
    }
}

- (void)processPendingMessages
{
    __weak typeof(self) weakSelf = self;
    NSUInteger pendingMessageCount = self.pendingMessages.count;
    if (!weakSelf || pendingMessageCount== 0) {
        return;
    }
    
    
    if (weakSelf.tableView.isDecelerating || weakSelf.tableView.isDragging)
    {
        //滑动的时候为保证流畅，暂停插入
        NSTimeInterval delay = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), SAMCMessageDataPrepareQueue(), ^{
            [weakSelf processPendingMessages];
        });
        return;
    }
    
    //获取一定量的消息计算高度，并扔回到主线程
    static NSInteger NTESMaxInsert = 2;
    NSArray *insert = nil;
    NSRange range;
    if (pendingMessageCount > NTESMaxInsert)
    {
        range = NSMakeRange(0, NTESMaxInsert);
    }
    else
    {
        range = NSMakeRange(0, pendingMessageCount);
    }
    insert = [self.pendingMessages subarrayWithRange:range];
    [self.pendingMessages removeObjectsInRange:range];
    
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NIMMessage *message in insert)
    {
        NIMMessageModel *model = [[NIMMessageModel alloc] initWithMessage:message spMode:(_samcSession.sessionMode==SAMCUserModeTypeSP)];
        [self layoutConfig:model];
        [models addObject:model];
    }
    
    NSUInteger leftPendingMessageCount = self.pendingMessages.count;
    BOOL animated = leftPendingMessageCount== 0;
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *insert = [weakSelf.sessionDatasource addMessageModels:models];
        [weakSelf.tableView beginUpdates];
        [weakSelf.layoutManager insertTableViewCellAtRows:insert animated:animated];
        [weakSelf.tableView endUpdates];
    });
    
    if (leftPendingMessageCount)
    {
        NSTimeInterval delay = 0.1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), SAMCMessageDataPrepareQueue(), ^{
            [weakSelf processPendingMessages];
        });
    }
}

- (void)checkReceipt
{
    if ([self shouldHandleReceipt])
    {
        NSDictionary *models = [self.sessionDatasource checkReceipt];
        for (NSNumber *index in models.allKeys) {
            [_layoutManager updateCellAtIndex:[index integerValue]
                                        model:models[index]];
        }
    }
}

- (BOOL)isCurrentModeMessage:(NIMMessage *)message
{
    if (message.session.sessionType != NIMSessionTypeP2P) {
        return YES;
    }
    id ext = message.remoteExt;
    SAMCUserModeType messageMode = SAMCUserModeTypeCustom;
    if (([[ext valueForKey:MESSAGE_EXT_FROM_USER_MODE_KEY] isEqual:MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM])) {
        // from custom user mode, local should display in sp mode
        if (!message.isOutgoingMsg) {
            messageMode = SAMCUserModeTypeSP;
        }
    } else {
        if (message.isOutgoingMsg) {
            messageMode = SAMCUserModeTypeSP;
        }
    }
    return (messageMode == _samcSession.sessionMode);
}

@end

