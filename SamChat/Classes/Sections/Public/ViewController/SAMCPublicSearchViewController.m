//
//  SAMCPublicSearchViewController.m
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSearchViewController.h"
#import "SAMCPublicManager.h"
#import "UIView+Toast.h"
#import "SAMCNavSearchBar.h"
#import "SAMCPublicSearchResultCell.h"
#import "SAMCPublicManager.h"
#import "SAMCAccountManager.h"
#import "SAMCServicerCardViewController.h"

@interface SAMCPublicSearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SAMCPublicSearchResultDelegate>

@property (nonatomic, strong) SAMCNavSearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SAMCPublicSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_MAIN_BACKGROUNDCOLOR;
    [self.navigationItem setHidesBackButton:YES];
    
    _searchBar = [[SAMCNavSearchBar alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width-16, 44)];
    _searchBar.showsCancelButton = YES;
    for (UIView* subview in [[_searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField*)subview;
            [textField setBackgroundColor:SAMC_MAIN_BACKGROUNDCOLOR];
        }
    }
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *key = self.searchBar.text;
    [self.data removeAllObjects];
    [self.tableView reloadData];
    __weak typeof(self) wself = self;
    [[SAMCPublicManager sharedManager] searchPublicWithKey:key location:nil completion:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (error) {
            NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
            [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
            return;
        }
        DDLogDebug(@"public: %@", users);
        for (NSDictionary *userDict in users) {
            SAMCUser *user = [SAMCUser userFromDict:userDict];
            [wself.data addObject:user];
            [wself.tableView reloadData];
        }
    }];
}

#pragma mark - SAMCPublicSearchResultDelegate
- (void)follow:(BOOL)isFollow user:(SAMCUser *)user completion:(void (^)(BOOL))completion
{
    __weak typeof(self) wself = self;
    [[SAMCPublicManager sharedManager] follow:isFollow officialAccount:user.spBasicInfo completion:^(NSError * _Nullable error) {
        NSString *toast;
        if (error) {
            toast =error.userInfo[NSLocalizedDescriptionKey];
            completion(NO);
        } else {
            if (isFollow) {
                toast = @"follow success";
                [[SAMCAccountManager sharedManager] updateUser:user];
                [self.myFollowIdList addObject:user.userId];
            } else {
                toast = @"unfollow success";
                [self.myFollowIdList removeObject:user.userId];
            }
            completion(YES);
        }
        [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCPublicSearchCellId";
    SAMCPublicSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCPublicSearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.delegate = self;
    }
    
    SAMCUser *user = self.data[indexPath.row];
    cell.user = user;
    cell.isFollowed = [self.myFollowIdList containsObject:user.userId];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SAMCServicerCardViewController *vc = [[SAMCServicerCardViewController alloc] initWithUser:self.data[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Private
- (NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

@end
