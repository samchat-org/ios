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
@property (nonatomic, strong) UISearchDisplayController *searchResultController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) SAMCTableViewDelegate *delegator;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SAMCPublicListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupSubviews
{
    [self.data removeAllObjects];
    [self.data addObjectsFromArray:[[SAMCPublicManager sharedManager] myFollowList]];
    __weak typeof(self) weakSelf = self;
    self.delegator = [[SAMCCustomPublicListDelegate alloc] initWithTableData:^NSMutableArray *{
        return weakSelf.data;
    } viewController:self];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.navigationItem.title = @"Public";
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor greenColor];
    self.tableView.dataSource = self.delegator;
    self.tableView.delegate = self.delegator;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tableView.tableHeaderView = self.searchBar;
    
    //    self.searchResultController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
    //                                                                          contentsController:self];
    //    self.searchResultController.delegate = self;
    //    self.searchResultController.searchResultsDataSource = self;
    //    self.searchResultController.searchResultsDelegate = self;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

#pragma mark - SAMCTableReloadDelegate
- (void)sortAndReload
{
    // TODO: add sorting
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self.tableView reloadData];
    } else {
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // TODO: just for test
    SAMCPublicSearchViewController *vc = [[SAMCPublicSearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *value, NSDictionary<NSString *,id> * _Nullable bindings) {
    //        NSRange range = [value rangeOfString:searchText options:NSCaseInsensitiveSearch];
    //        return range.location != NSNotFound;
    //    }];
    //
    //    NSMutableArray *tempResultArray = [[NSMutableArray alloc] init];
    //    [self.countryCodeDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL * _Nonnull stop) {
    //        if ([key isEqualToString:@"#"]) {
    //            return;
    //        }
    //        [tempResultArray addObjectsFromArray:[obj filteredArrayUsingPredicate:predicate]];
    //    }];
    //
    //    self.searchResultArray = [tempResultArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
    //        return [obj1 compare:obj2];
    //    }];
    //    [self.searchResultController.searchResultsTableView reloadData];
}

- (void)headerRereshing:(id)sender
{
    //    __weak NIMSessionViewLayoutManager *layoutManager = self.layoutManager;
    //    __weak typeof(self) wself = self;
    //    __weak UIRefreshControl *refreshControl = self.refreshControl;
    //    [self.sessionDatasource loadHistoryMessagesWithComplete:^(NSInteger index,NSArray *memssages, NSError *error) {
    //        [refreshControl endRefreshing];
    //        if (memssages.count) {
    //            [layoutManager reloadData];
    //            [wself checkAttachmentState:memssages];
    //            [wself checkReceipt];
    //        }
    //    }];
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
