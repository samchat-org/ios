//
//  SAMCPublicViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicViewController.h"
#import "SAMCPublicSearchViewController.h"
#import "SAMCCustomPublicListDelegate.h"
#import "SAMCPublicManager.h"

@interface SAMCPublicViewController ()<SAMCTableReloadDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *customTableView;
@property (nonatomic, strong) UISearchDisplayController *customSearchResultController;
@property (nonatomic, strong) UISearchBar *customSearchBar;

@property (nonatomic, strong) UITableView *spTableView;

@property (nonatomic, strong) SAMCTableViewDelegate *delegator;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SAMCPublicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)switchToUserMode:(NSNotification *)notification
{
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    if (mode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)setupCustomModeViews
{
    [self.data removeAllObjects];
    [self.data addObjectsFromArray:[[SAMCPublicManager sharedManager] myFollowList]];
    __weak typeof(self) weakSelf = self;
    self.delegator = [[SAMCCustomPublicListDelegate alloc] initWithTableData:^NSMutableArray *{
        return weakSelf.data;
    } viewController:self];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.spTableView = nil;
    
    self.navigationItem.title = @"Public";
    
    self.customTableView = [[UITableView alloc] init];
    self.customTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.customTableView.backgroundColor = [UIColor greenColor];
    self.customTableView.dataSource = self.delegator;
    self.customTableView.delegate = self.delegator;
    self.customTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.customTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.customTableView];
    
    self.customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.customSearchBar.delegate = self;
    self.customSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.customTableView.tableHeaderView = self.customSearchBar;
    
//    self.customSearchResultController = [[UISearchDisplayController alloc] initWithSearchBar:self.customSearchBar
//                                                                          contentsController:self];
//    self.customSearchResultController.delegate = self;
//    self.customSearchResultController.searchResultsDataSource = self;
//    self.customSearchResultController.searchResultsDelegate = self;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_customTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_customTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_customTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_customTableView)]];
}

- (void)setupSPModeViews
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.customTableView = nil;
    self.customSearchBar = nil;
    self.customSearchResultController = nil;
    self.delegator = nil;
    
    self.navigationItem.title = @"My Public Updates";
    
    self.spTableView = [[UITableView alloc] init];
    self.spTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.spTableView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.spTableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_spTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_spTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_spTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_spTableView)]];
}

#pragma mark - SAMCTableReloadDelegate
- (void)sortAndReload
{
    // TODO: add sorting
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self.customTableView reloadData];
    } else {
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // TODO: just for test
    SAMCPublicSearchViewController *vc = [[SAMCPublicSearchViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - lazy load
- (NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

@end
