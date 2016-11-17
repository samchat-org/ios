//
//  SAMCPublicListViewController.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicListViewController.h"
#import "SAMCPublicManager.h"
#import "SAMCPublicSearchViewController.h"
#import "SAMCCustomPublicListCell.h"
#import "SAMCPublicMessageViewController.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"

@interface SAMCPublicListViewController ()<UITableViewDataSource,UITableViewDelegate,SAMCPublicManagerDelegate,NIMUserManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SAMCPublicListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _data = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupSubviews];
    [self setUpNavItem];
    [[SAMCPublicManager sharedManager] addDelegate:self];
    [[NIMSDK sharedSDK].userManager addDelegate:self];
}

- (void)dealloc
{
    [[SAMCPublicManager sharedManager] removeDelegate:self];
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.parentViewController.navigationItem.title = @"Public";
    [self.data removeAllObjects];
    [self.data addObjectsFromArray:[[SAMCPublicManager sharedManager] myFollowList]];
    [self sort];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)setUpNavItem
{
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn addTarget:self action:@selector(searchPublic:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setImage:[UIImage imageNamed:@"ico_nav_add_light"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"ico_nav_add_light_pressed"] forState:UIControlStateHighlighted];
    [addBtn sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.parentViewController.navigationItem.rightBarButtonItem = addItem;
}

#pragma mark - Action
- (void)searchPublic:(id)sender
{
    SAMCPublicSearchViewController *vc = [[SAMCPublicSearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCCustomPublicListCellId";
    SAMCCustomPublicListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCCustomPublicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SAMCPublicSession *session = [self data][indexPath.row];
    cell.publicSession = session;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SAMCPublicMessageViewController *vc = [[SAMCPublicMessageViewController alloc] init];
    SAMCPublicSession *session = [self data][indexPath.row];
    vc.publicSession = session;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[[self unfollowAction], [self muteAction:indexPath], [self blockAction:indexPath]];
}

#pragma mark - SAMCPublicManagerDelegate
- (void)didAddPublicSession:(SAMCPublicSession *)publicSession
{
    [[self data] addObject:publicSession];
    [self sort];
    [self reload];
}

- (void)didUpdatePublicSession:(SAMCPublicSession *)publicSession
{
    NSMutableArray *sessions= [self data];
    for (SAMCPublicSession *session in sessions) {
        if ([session isEqual:publicSession]) {
            [sessions removeObject:session];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:publicSession];
    [sessions insertObject:publicSession atIndex:insert];
    [self reload];
}

- (void)didRemovePublicSession:(SAMCPublicSession *)publicSession
{
    NSInteger index = [[self data] indexOfObject:publicSession];
    if (index == NSNotFound) {
        [self.tableView reloadData];
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [[self data] removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didUpdateFollowList
{
    [self.data removeAllObjects];
    [self.data addObjectsFromArray:[[SAMCPublicManager sharedManager] myFollowList]];
    [self sort];
    [self reload];
}

#pragma mark - NIMUserManagerDelegate
- (void)onMuteListChanged
{
    [self reload];
}

#pragma mark - 
- (void)sort
{
    [self.data sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SAMCPublicSession *item1 = obj1;
        SAMCPublicSession *item2 = obj2;
        if (item1.lastMessageTime < item2.lastMessageTime) {
            return NSOrderedDescending;
        }
        if (item1.lastMessageTime > item2.lastMessageTime) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)reload
{
    [self.tableView reloadData];
}

- (NSInteger)findInsertPlace:(SAMCPublicSession *)session
{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SAMCPublicSession *item = obj;
        if (item.lastMessageTime <= session.lastMessageTime) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.data.count;
    }
}

- (NSString *)publicUserIdOfSession:(SAMCPublicSession *)session
{
    return [NSString stringWithFormat:@"%@%@",SAMC_PUBLIC_ACCOUNT_PREFIX,session.userId];
}

#pragma mark - UITableViewRowAction
- (UITableViewRowAction *)blockAction:(NSIndexPath *)indexPath
{
    __weak typeof(self) wself = self;
    SAMCPublicSession *session = [self data][indexPath.row];
    NSString *userId = session.userId;
    BOOL isBlock = session.spBasicInfo.blockTag;
    NSString *title = isBlock ? @"Unblock":@"Block";
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [wself.tableView setEditing:NO animated:YES];
        [SVProgressHUD show];
        [[SAMCPublicManager sharedManager] block:!isBlock user:userId completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (error) {
                [wself.view makeToast:@"操作失败"duration:2.0f position:CSToastPositionCenter];
            } else {
                [wself.view makeToast:@"操作成功"duration:2.0f position:CSToastPositionCenter];
            }
        }];
    }];
    action.backgroundColor = SAMC_COLOR_LIMEGREY;
    return action;
}

- (UITableViewRowAction *)muteAction:(NSIndexPath *)indexPath
{
    __weak typeof(self) wself = self;
    SAMCPublicSession *session = [self data][indexPath.row];
    NSString *publicUserId = [self publicUserIdOfSession:session];
    BOOL needNotify = [[NIMSDK sharedSDK].userManager notifyForNewMsg:publicUserId];
    NSString *title = needNotify ? @"Mute" : @"Unmute";
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [wself.tableView setEditing:NO animated:YES];
        [SVProgressHUD show];
        [[NIMSDK sharedSDK].userManager updateNotifyState:!needNotify forUser:publicUserId completion:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (error) {
                [wself.view makeToast:@"操作失败" duration:2.0f position:CSToastPositionCenter];
            }
        }];

    }];
    action.backgroundColor = SAMC_COLOR_GREY;
    return action;
}

- (UITableViewRowAction *)unfollowAction
{
    __weak typeof(self) wself = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unfollow" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        SAMCPublicSession *session = [wself data][indexPath.row];
        [SVProgressHUD show];
        [[SAMCPublicManager sharedManager] follow:NO officialAccount:session.spBasicInfo completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            // use SAMCPublicManagerDelegate to delete
        }];
    }];
    action.backgroundColor = SAMC_COLOR_RED;
    return action;
}

@end
