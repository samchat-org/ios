//
//  SAMCPublicListViewController.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicListViewController.h"
#import "SAMCCustomPublicListDelegate.h"
#import "SAMCPublicManager.h"
#import "SAMCPublicSearchViewController.h"

@interface SAMCPublicListViewController ()<SAMCTableReloadDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SAMCTableViewDelegate *delegator;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SAMCPublicListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupSubviews];
    [self setUpNavItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.parentViewController.navigationItem.title = @"Public";
    [self.data removeAllObjects];
    [self.data addObjectsFromArray:[[SAMCPublicManager sharedManager] myFollowList]];
    __weak typeof(self) weakSelf = self;
    self.delegator = [[SAMCCustomPublicListDelegate alloc] initWithTableData:^NSMutableArray *{
        return weakSelf.data;
    } viewController:self];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self.delegator;
    self.tableView.delegate = self.delegator;
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
    //    [addBtn setImage:[UIImage imageNamed:@"public_add_pressed"] forState:UIControlStateHighlighted];
    [addBtn sizeToFit];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.parentViewController.navigationItem.rightBarButtonItem = addItem;
}

#pragma mark - Action
- (void)searchPublic:(id)sender
{
    SAMCPublicSearchViewController *vc = [[SAMCPublicSearchViewController alloc] init];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for (SAMCPublicSession *session in self.data) {
        [ids addObject:session.userId];
    }
    vc.myFollowIdList = ids;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SAMCTableReloadDelegate
- (void)sortAndReload
{
    // TODO: add sorting
    [self.tableView reloadData];
}

#pragma mark - lazy load
- (NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}
@end
