//
//  SAMCPublicMessageViewController.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMessageViewController.h"

@import MobileCoreServices;
#import <AVFoundation/AVFoundation.h>
#import "UIActionSheet+NTESBlock.h"
#import "NIMMediaItem.h"
#import "NTESFileLocationHelper.h"
#import "NTESSessionMsgConverter.h"
#import "UIView+Toast.h"
#import "NTESGalleryViewController.h"
#import "NSDictionary+NTESJson.h"
#import "UIView+NTES.h"
#import "NTESPersonalCardViewController.h"
#import "NIMContactSelectViewController.h"
#import "SVProgressHUD.h"
#import "UIAlertView+NTESBlock.h"
#import "NTESDataManager.h"
#import "NIMInputView.h"
#import "NIMInputTextView.h"
#import "UIView+NIM.h"
#import "NIMMessageCellProtocol.h"
#import "NIMMessageModel.h"
#import "NIMKitUtil.h"
#import "UITableView+NIMScrollToBottom.h"
#import "NIMMessageMaker.h"
#import "NIMDefaultValueMaker.h"
#import "NIMTimestampModel.h"
#import "NIMMessageCellMaker.h"
#import "NIMUIConfig.h"
#import "NIMKit.h"
#import "SAMCPublicSessionConfig.h"
#import "SAMCPublicManager.h"
#import "SAMCPublicMessageMaker.h"
#import "SAMCPublicMsgDataSource.h"
#import "SAMCPublicMsgCellLayoutConfig.h"
#import "SAMCPublicCustomMsgCellLayoutConfig.h"
#import "SAMCImageAttachment.h"
#import "SAMCAccountManager.h"
#import "SAMCPublicInputView.h"
#import "NIMInputToolBar.h"
#import "SAMCPublicSessionViewLayoutManager.h"

@interface SAMCPublicMessageViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
NIMInputActionDelegate,
NIMMessageCellDelegate,
SAMCPublicMsgDatasourceDelegate,
SAMCPublicManagerDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) SAMCPublicSessionViewLayoutManager *layoutManager;

@property (nonatomic, strong) SAMCPublicMsgDataSource *sessionDatasource;
@property (nonatomic, strong) NIMMessage *messageForMenu;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) SAMCPublicInputView *publicInputView;

@end

@implementation SAMCPublicMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeUI];
    [self makeHandlerAndDataSource];
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[SAMCPublicManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)makeUI
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.tableView addSubview:_refreshControl];
    [self.refreshControl addTarget:self action:@selector(headerRereshing:) forControlEvents:UIControlEventValueChanged];
    
    CGRect inputViewRect = CGRectMake(0, 0, self.view.nim_width, [NIMUIConfig topInputViewHeight]);
    
    if ([self.publicSession isOutgoing]) {
        [self setUpNavItem];
        _publicInputView = [[SAMCPublicInputView alloc] initWithFrame:inputViewRect];
        _publicInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _publicInputView.nim_bottom = self.view.height;
        [_publicInputView setInputConfig:[[SAMCPublicSessionConfig alloc] init]];
        [_publicInputView setInputActionDelegate:self];
        [self.view addSubview:_publicInputView];
    } else {
        self.navigationItem.title = self.publicSession.spBasicInfo.username;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)setUpNavItem
{
    self.parentViewController.navigationItem.title = @"My Public Updates";
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn addTarget:self action:@selector(newPublicMessage:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setImage:[UIImage imageNamed:@"ico_public_new"] forState:UIControlStateNormal];
    [addBtn sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.parentViewController.navigationItem.rightBarButtonItem = addItem;
}

- (void)makeHandlerAndDataSource
{
    _layoutManager = [[SAMCPublicSessionViewLayoutManager alloc] initWithInputView:self.publicInputView tableView:self.tableView];
    
    //数据
    NSInteger limit = 10;
    NSTimeInterval showTimestampInterval = 0;//[NIMUIConfig messageTimeInterval];
    _sessionDatasource = [[SAMCPublicMsgDataSource alloc] initWithSession:self.publicSession showTimeInterval:showTimestampInterval limit:limit];
    _sessionDatasource.delegate = self;
    
    [_sessionDatasource resetMessages:nil];
    
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    for (id model in _sessionDatasource.modelArray) {
        if ([model isKindOfClass:[NIMMessageModel class]])
        {
            [messageArray addObject:[model message]];
        }
    }
    [self checkAttachmentState:messageArray];
    
    [[SAMCPublicManager sharedManager] addDelegate:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    BOOL isFirstLayout = CGRectEqualToRect(_layoutManager.viewRect, CGRectZero);
    if (isFirstLayout) {
        [self.tableView nim_scrollToBottom:NO];
    }
    [_layoutManager setViewRect:self.view.frame];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_publicInputView endEditing:YES];
}

- (void)checkAttachmentState:(NSArray *)messages{
    for (NIMMessage *message in messages) {
        if (message.attachmentDownloadState == NIMMessageAttachmentDownloadStateNeedDownload) {
            [[NIMSDK sharedSDK].chatManager fetchMessageAttachment:message error:nil];
        }
    }
}

- (void)newPublicMessage:(id)sender
{
    [self.publicInputView.toolBar.inputTextView becomeFirstResponder];
}

#pragma mark - 相册
- (void)mediaPicturePressed
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        
        SAMCPublicMessage *message = [SAMCPublicMessageMaker msgWithImage:orgImage];
        [self sendMessage:message];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell事件
- (void)onTapAvatar:(NSString *)userId
{
    UIViewController *vc = [[NTESPersonalCardViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Cell Actions
- (void)showCustom:(SAMCPublicMessage *)message
{
    NIMCustomObject * customObject = (NIMCustomObject*)message.messageObject;
    SAMCImageAttachment *attachment = (SAMCImageAttachment *)customObject.attachment;
    
    NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
    item.thumbPath      = attachment.thumbPath;
    item.imageURL       = attachment.url;
    item.name           = attachment.displayName;
    NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:attachment.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:attachment.thumbUrl filepath:attachment.thumbPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    if (message.messageType == NIMMessageTypeText) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyText:)]];
    }
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMsg:)]];
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardMessage:)]];
    return items;
}

- (void)forwardMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择会话类型" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"个人",@"群组", nil];
    __weak typeof(self) weakSelf = self;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
                config.needMutiSelected = NO;
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *userId = array.firstObject;
                    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 1:{
                NIMContactTeamSelectConfig *config = [[NIMContactTeamSelectConfig alloc] init];
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *teamId = array.firstObject;
                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 2:
                break;
            default:
                break;
        }
    }];
}

- (void)forwardMessage:(NIMMessage *)message toSession:(NIMSession *)session
{
    NSString *name;
    if (session.sessionType == NIMSessionTypeP2P) {
        name = [[NTESDataManager sharedInstance] infoByUser:session.sessionId inSession:session].showName;
    }
    else {
        name = [[NTESDataManager sharedInstance] infoByTeam:session.sessionId].showName;
    }
    NSString *tip = [NSString stringWithFormat:@"确认转发给 %@ ?",name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认转发" message:tip delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    __weak typeof(self) weakSelf = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        if(index == 1){
            [[NIMSDK sharedSDK].chatManager forwardMessage:message toSession:session error:nil];
            [weakSelf.view makeToast:@"已发送" duration:2.0 position:CSToastPositionCenter];
        }
    }];
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
        cell = [NIMMessageCellMaker cellInTable:tableView forMessageMode:model];
        [(NIMMessageCell *)cell setMessageDelegate:self];
    }
    else if ([model isKindOfClass:[NIMTimestampModel class]]) {
        cell = [NIMMessageCellMaker cellInTable:tableView forTimeModel:model];
    }
    else {
        NSAssert(0, @"not support model");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    id modelInArray = [[_sessionDatasource modelArray] objectAtIndex:indexPath.row];
    if ([modelInArray isKindOfClass:[NIMMessageModel class]]) {
        NIMMessageModel *model = (NIMMessageModel *)modelInArray;
        NSAssert([model respondsToSelector:@selector(contentSize)], @"config must have a cell height value!!!");
        [self layoutConfig:model];
        CGSize size = model.contentSize;
        UIEdgeInsets contentViewInsets = model.contentViewInsets;
        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom;
    }
    else if ([modelInArray isKindOfClass:[NIMTimestampModel class]]) {
        cellHeight = [modelInArray height];
    }
    else {
        NSAssert(0, @"not support model");
    }
    return cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

#pragma mark - 消息收发接口
- (void)sendMessage:(SAMCPublicMessage *)message
{
    DDLogDebug(@"sendMessage: %@", message);
    message.publicSession = self.publicSession;
    message.from = [SAMCAccountManager sharedManager].currentAccount;
    [[SAMCPublicManager sharedManager] sendPublicMessage:message error:NULL];
}

#pragma mark - SAMCPublicManagerDelegate
- (void)willSendMessage:(SAMCPublicMessage *)message
{
    if ([message.publicSession isEqual:_publicSession]) {
        if ([self findModel:message]) {
            [self uiUpdateMessage:message];
        }else{
            [self uiAddMessages:@[message]];
        }
    }
}

- (void)sendMessage:(SAMCPublicMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.publicSession isEqual:_publicSession]) {
        NIMMessageModel *model = [self makeModel:message];
        NSInteger index = [self.sessionDatasource indexAtModelArray:model];
        [self.layoutManager updateCellAtIndex:index model:model];
    }
}

-(void)sendMessage:(SAMCPublicMessage *)message progress:(CGFloat)progress
{
    if ([message.publicSession isEqual:_publicSession]) {
        NIMMessageModel *model = [self makeModel:message];
        NSInteger index = [self.sessionDatasource indexAtModelArray:model];
        [self.layoutManager updateCellAtIndex:index model:model];
    }
}

- (void)onRecvMessage:(SAMCPublicMessage *)message
{
    if ([message.publicSession isEqual:_publicSession]) {
        [self uiAddMessages:@[message]];
    }
}

- (void)fetchMessageAttachment:(SAMCPublicMessage *)message progress:(CGFloat)progress
{
}

- (void)fetchMessageAttachment:(SAMCPublicMessage *)message didCompleteWithError:(NSError *)error
{
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_publicInputView endEditing:YES];
}

#pragma mark - NIMInputActionDelegate
- (void)onTapMediaItem:(NIMMediaItem *)item
{
    NSDictionary *actions = @{@(NTESMediaButtonPicture):@"mediaPicturePressed"};;
    NSString *value = actions[@(item.tag)];
    BOOL handled = NO;
    if (value) {
        SEL selector = NSSelectorFromString(value);
        if (selector && [self respondsToSelector:selector]) {
            SuppressPerformSelectorLeakWarning([self performSelector:selector]);
            handled = YES;
        }
    }
    if (!handled) {
        NSAssert(0, @"invalid item tag");
    }
}

- (void)onTextChanged:(id)sender
{
}

- (void)onSendText:(NSString *)text
{
    SAMCPublicMessage *message = [SAMCPublicMessageMaker msgWithText:text];
    [self sendMessage:message];
}

#pragma mark - NIMSessionMsgDatasourceDelegate
- (void)messageDataIsReady
{
    [self.tableView reloadData];
    [self.tableView nim_scrollToBottom:NO];
}

#pragma mark - NIMMessageCellDelegate
- (void)onTapCell:(NIMKitEvent *)event
{
    BOOL handled = NO;
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent]) {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = @{@(NIMMessageTypeCustom):@"showCustom:"};
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if([eventName isEqualToString:NIMKitEventNameTapLabelLink]) {
        NSString *link = event.data;
        [self.view makeToast:[NSString stringWithFormat:@"tap link : %@",link]
                    duration:2
                    position:CSToastPositionCenter];
        handled = YES;
    }
    
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
}

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
    SAMCPublicMessage *message = (SAMCPublicMessage *)[self messageForMenu];
    [self uiDeleteMessage:message];
    [[SAMCPublicManager sharedManager] deleteMessage:message];
}

- (void)menuDidHide:(NSNotification *)notification
{
    [UIMenuController sharedMenuController].menuItems = nil;
}

#pragma mark - 操作接口
- (void)uiAddMessages:(NSArray *)messages
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NIMMessage *message in messages) {
        NIMMessageModel *model = [[NIMMessageModel alloc] initWithMessage:message];
        [self layoutConfig:model];
        [models addObject:model];
    }
    NSArray *insert = [self.sessionDatasource addMessageModels:models];
    [self.tableView beginUpdates];
    [self.layoutManager insertTableViewCellAtRows:insert animated:YES];
    [self.tableView endUpdates];
}

- (void)uiDeleteMessage:(NIMMessage *)message
{
    NIMMessageModel *model = [self findModel:message];
    NSArray *indexs = [self.sessionDatasource deleteMessageModel:model];
    [self.tableView beginUpdates];
    [self.layoutManager deleteCellAtIndexs:indexs];
    [self.tableView endUpdates];
}

- (void)uiUpdateMessage:(NIMMessage *)message
{
    NIMMessageModel *model = [self findModel:message];
    NSInteger index = [self.sessionDatasource indexAtModelArray:model];
    [self.sessionDatasource.modelArray replaceObjectAtIndex:index withObject:model];
    [self.layoutManager updateCellAtIndex:index model:model];
}

#pragma mark - Private
- (void)layoutConfig:(NIMMessageModel *)model
{
    if (model.message.messageType == NIMMessageTypeCustom) {
        model.layoutConfig = [[SAMCPublicCustomMsgCellLayoutConfig alloc] init];
    } else {
        model.layoutConfig = [[SAMCPublicMsgCellLayoutConfig alloc] init];
    }
    [model calculateContent:self.tableView.nim_width force:NO];
}

- (NIMMessageModel *)makeModel:(NIMMessage *)message
{
    NIMMessageModel *model = [self findModel:message];
    if (!model) {
        model = [[NIMMessageModel alloc] initWithMessage:message];
        model.shouldShowReadLabel = NO;
    }
    [self layoutConfig:model];
    return model;
}

- (NIMMessageModel *)findModel:(NIMMessage *)message
{
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
    __weak SAMCPublicSessionViewLayoutManager *layoutManager = self.layoutManager;
    __weak typeof(self) wself = self;
    __weak UIRefreshControl *refreshControl = self.refreshControl;
    [self.sessionDatasource loadHistoryMessagesWithComplete:^(NSInteger index,NSArray *memssages, NSError *error) {
        [refreshControl endRefreshing];
        if (memssages.count) {
            [layoutManager reloadData];
            [wself checkAttachmentState:memssages];
        }
    }];
}

@end
