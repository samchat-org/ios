//
//  SAMCSPServiceViewController.m
//  SamChat
//
//  Created by HJ on 10/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPServiceViewController.h"
#import "SAMCNewRequestViewController.h"
#import "SAMCQuestionManager.h"
#import "SAMCServiceProfileViewController.h"
#import "SAMCAddContactViewController.h"
#import "SAMCSPRequestListCell.h"
#import "SAMCSessionViewController.h"

@interface SAMCSPServiceViewController()<UITableViewDataSource,UITableViewDelegate,SAMCQuestionManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *theNewQuestions;
@property (nonatomic, strong) NSMutableArray *theSeenQuestions;

@property (nonatomic, strong) UILabel *noRequestTipLabel;
@property (nonatomic, strong) UILabel *noRequestDetailLabel;
@property (nonatomic, strong) UIButton *updateSPProfileButton;
@property (nonatomic, strong) UIButton *sendPublicUpdateButton;
@property (nonatomic, strong) UIButton *addCustomerButton;

@end

@implementation SAMCSPServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _theNewQuestions = [[NSMutableArray alloc] init];
    _theSeenQuestions = [[NSMutableArray alloc] init];
    [self setupSubviews];
    [[SAMCQuestionManager sharedManager] addDelegate:self];
}

- (void)dealloc
{
    [[SAMCQuestionManager sharedManager] removeDelegate:self];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.parentViewController.navigationItem.title = @"Service Requests";
    
    [self.theNewQuestions removeAllObjects];
    [self.theSeenQuestions removeAllObjects];
    NSArray *allReceivedQuestion = [[SAMCQuestionManager sharedManager] allReceivedQuestion];
    [allReceivedQuestion enumerateObjectsUsingBlock:^(SAMCQuestionSession *questionSession, NSUInteger idx, BOOL * _Nonnull stop) {
        if (questionSession.status == SAMCReceivedQuestionStatusNew) {
            [self.theNewQuestions addObject:questionSession];
        } else {
            [self.theSeenQuestions addObject:questionSession];
        }
    }];
    [self sort];
    
    [self setupSPModeNotEmptyRequestViews];
    [self setupSPModeEmptyRequestViews];
}

- (void)setupSPModeEmptyRequestViews
{
    [self.view addSubview:self.noRequestTipLabel];
    [self.view addSubview:self.noRequestDetailLabel];
    [self.view addSubview:self.updateSPProfileButton];
    [self.view addSubview:self.sendPublicUpdateButton];
    [self.view addSubview:self.addCustomerButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_noRequestTipLabel]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_noRequestTipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[_noRequestDetailLabel]-48-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_noRequestDetailLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_updateSPProfileButton]-50-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_updateSPProfileButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_sendPublicUpdateButton]-50-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_sendPublicUpdateButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_addCustomerButton]-50-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_addCustomerButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_noRequestTipLabel]-12-[_noRequestDetailLabel]-20-[_updateSPProfileButton(40)]-10-[_sendPublicUpdateButton(40)]-10-[_addCustomerButton(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_noRequestTipLabel,_noRequestDetailLabel,_updateSPProfileButton,_sendPublicUpdateButton,_addCustomerButton)]];
    if (([self.theNewQuestions count] > 0) || ([self.theSeenQuestions count] > 0)) {
        [self hideSPEmptyRequestView:YES];
    }
}

- (void)setupSPModeNotEmptyRequestViews
{
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                               //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_tableView]|",SAMCTopBarHeight]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    if (([self.theNewQuestions count] == 0) && ([self.theSeenQuestions count] == 0)) {
        [self hideSPNotEmptyRequestView:YES];
    }
}

- (void)hideSPEmptyRequestView:(BOOL)hidden
{
    self.noRequestTipLabel.hidden = hidden;
    self.noRequestDetailLabel.hidden = hidden;
    self.updateSPProfileButton.hidden = hidden;
    self.sendPublicUpdateButton.hidden = hidden;
    self.addCustomerButton.hidden = hidden;
}

- (void)hideSPNotEmptyRequestView:(BOOL)hidden
{
    self.tableView.hidden = hidden;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.theNewQuestions count];
    } else {
        return [self.theSeenQuestions count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if ((section == 0) && ([self.theNewQuestions count] > 0)) {
        title = @"new";
    } else if ((section == 1) && ([self.theSeenQuestions count] > 0)){
        title = @"seen";
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SAMCSPRequestListCellId";
    SAMCSPRequestListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCSPRequestListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    SAMCQuestionSession *session = [self questionSessionAtIndexPath:indexPath];
    [cell updateWithSession:session];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (((section == 0) && ([self.theNewQuestions count] == 0))
        || ((section == 1) && ([self.theSeenQuestions count] == 0))) {
        return CGFLOAT_MIN;
    }
    return 32.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SAMCQuestionSession *questionsession = [self questionSessionAtIndexPath:indexPath];
    [self saveQuestionMessage:questionsession];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAMCQuestionSession *session = [self questionSessionAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[SAMCQuestionManager sharedManager] deleteReceivedQuestion:session];
        if ([self needRefreshAfterRemoveQuestionSessionAtIndexPath:indexPath]) {
            [self sort];
            [self reload];
        } else {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - SAMCQuestionManagerDelegate
- (void)didAddQuestionSession:(SAMCQuestionSession *)questionSession
{
    if (questionSession.type != SAMCQuestionSessionTypeReceived) {
        return;
    }
    [self.theNewQuestions addObject:questionSession];
    [self sort];
    [self reload];
}

- (SAMCQuestionSession *)questionSessionAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.theNewQuestions[indexPath.row];
    } else {
        return self.theSeenQuestions[indexPath.row];
    }
}

- (BOOL)needRefreshAfterRemoveQuestionSessionAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.theNewQuestions removeObjectAtIndex:indexPath.row];
        return ([self.theNewQuestions count] == 0);
    } else {
        [self.theSeenQuestions removeObjectAtIndex:indexPath.row];
        return ([self.theSeenQuestions count] == 0);
    }
}

#pragma mark - Insert Message
- (void)saveQuestionMessage:(SAMCQuestionSession *)questionSession
{
    if (questionSession.status != SAMCReceivedQuestionStatusNew) {
        [self pushToSessionViewController:questionSession];
        return;
    }
    
    NSString *senderId = [NSString stringWithFormat:@"%@",@(questionSession.senderId)];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = questionSession.question;
    message.from = senderId;
    
    // set unread flag extention
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:message.remoteExt];
    [ext addEntriesFromDictionary:@{MESSAGE_EXT_FROM_USER_MODE_KEY:MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM,
                                    MESSAGE_EXT_UNREAD_FLAG_KEY:MESSAGE_EXT_UNREAD_FLAG_NO}];
    message.remoteExt = ext;
    NIMSession *session = [NIMSession session:senderId type:NIMSessionTypeP2P];
    
    questionSession.status = SAMCReceivedQuestionStatusInserted;
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:^(NSError * _Nullable error) {
        [wself pushToSessionViewController:questionSession];
        if (error) {
            questionSession.status = SAMCReceivedQuestionStatusNew;
        } else {
            [[SAMCQuestionManager sharedManager] updateReceivedQuestion:questionSession.questionId status:SAMCReceivedQuestionStatusInserted];
            [wself.theNewQuestions removeObject:questionSession];
            [wself.theSeenQuestions addObject:questionSession];
            [wself sort];
            [wself reload];
        }
    }];
}

- (void)pushToSessionViewController:(SAMCQuestionSession *)questionSession
{
    NSString *senderId = [NSString stringWithFormat:@"%@",@(questionSession.senderId)];
    SAMCSession *samcsession = [SAMCSession session:senderId type:NIMSessionTypeP2P mode:SAMCUserModeTypeSP];
    SAMCSessionViewController *vc = [[SAMCSessionViewController alloc] initWithSession:samcsession];
    // 如果问题未回复，则设置vc的问题，vc中会判断此项，如果存在，则会加入到发送消息的扩展中
    // 并在发送消息回调中判断，发送成功时会更新数据库，同时vc中根据发送成功也会置为nil，使得之后发送的消息中不带扩展
    if (questionSession.status != SAMCReceivedQuestionStatusResponsed) {
        vc.questionId = @(questionSession.questionId);
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
- (void)reload
{
    if (([self.theNewQuestions count] > 0) || ([self.theSeenQuestions count] > 0)) {
        [self hideSPNotEmptyRequestView:NO];
        [self hideSPEmptyRequestView:YES];
        [self.tableView reloadData];
    } else {
        [self hideSPNotEmptyRequestView:YES];
        [self hideSPEmptyRequestView:NO];
    }
}

- (void)sort
{
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2) {
        SAMCQuestionSession *item1 = obj1;
        SAMCQuestionSession *item2 = obj2;
        if (item1.datetime < item2.datetime) {
            return NSOrderedDescending;
        }
        if (item1.datetime > item2.datetime) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    };
    [self.theNewQuestions sortUsingComparator:comparator];
    [self.theSeenQuestions sortUsingComparator:comparator];
}

#pragma mark - Action
- (void)touchUpdateServiceProfile:(id)sender
{
    SAMCServiceProfileViewController *vc = [[SAMCServiceProfileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchSendPublicUpdate:(id)sender
{
    self.tabBarController.selectedIndex = 1;
}

- (void)touchAddCustomer:(id)sender
{
    SAMCAddContactViewController *vc = [[SAMCAddContactViewController alloc] init];
    vc.currentUserMode = SAMCUserModeTypeSP;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy load
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.estimatedRowHeight = 100;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

- (UILabel *)noRequestTipLabel
{
    if (_noRequestTipLabel == nil) {
        _noRequestTipLabel = [[UILabel alloc] init];
        _noRequestTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noRequestTipLabel.font = [UIFont systemFontOfSize:19.0f];
        _noRequestTipLabel.textColor = SAMC_COLOR_INK;
        _noRequestTipLabel.text = @"No request yet, take a break!";
        _noRequestTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noRequestTipLabel;
}

- (UILabel *)noRequestDetailLabel
{
    if (_noRequestDetailLabel == nil) {
        _noRequestDetailLabel = [[UILabel alloc] init];
        _noRequestDetailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noRequestDetailLabel.font = [UIFont systemFontOfSize:15.0f];
        _noRequestDetailLabel.numberOfLines = 0;
        _noRequestDetailLabel.textColor = SAMC_COLOR_BODY_MID;
        _noRequestDetailLabel.text = @"Meanwhile, tell us more about your service and professional experience to increase your chance of getting a match.";
        _noRequestDetailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noRequestDetailLabel;
}

- (UIButton *)updateSPProfileButton
{
    if (_updateSPProfileButton == nil) {
        _updateSPProfileButton = [[UIButton alloc] init];
        _updateSPProfileButton.translatesAutoresizingMaskIntoConstraints = NO;
        _updateSPProfileButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_updateSPProfileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _updateSPProfileButton.backgroundColor = SAMC_COLOR_LAKE;
        _updateSPProfileButton.layer.cornerRadius = 20.0f;
        [_updateSPProfileButton setTitle:@"Update Service Profile" forState:UIControlStateNormal];
        [_updateSPProfileButton addTarget:self action:@selector(touchUpdateServiceProfile:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateSPProfileButton;
}

- (UIButton *)sendPublicUpdateButton
{
    if (_sendPublicUpdateButton == nil) {
        _sendPublicUpdateButton = [[UIButton alloc] init];
        _sendPublicUpdateButton.translatesAutoresizingMaskIntoConstraints = NO;
        _sendPublicUpdateButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_sendPublicUpdateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendPublicUpdateButton.backgroundColor = SAMC_COLOR_GREY;
        _sendPublicUpdateButton.layer.cornerRadius = 20.0f;
        [_sendPublicUpdateButton setTitle:@"Send Public Update" forState:UIControlStateNormal];
        [_sendPublicUpdateButton addTarget:self action:@selector(touchSendPublicUpdate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendPublicUpdateButton;
}

- (UIButton *)addCustomerButton
{
    if (_addCustomerButton == nil) {
        _addCustomerButton = [[UIButton alloc] init];
        _addCustomerButton.translatesAutoresizingMaskIntoConstraints = NO;
        _addCustomerButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_addCustomerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addCustomerButton.backgroundColor = SAMC_COLOR_GREY;
        _addCustomerButton.layer.cornerRadius = 20.0f;
        [_addCustomerButton setTitle:@"Add Existing Customers" forState:UIControlStateNormal];
        [_addCustomerButton addTarget:self action:@selector(touchAddCustomer:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addCustomerButton;
}

@end
