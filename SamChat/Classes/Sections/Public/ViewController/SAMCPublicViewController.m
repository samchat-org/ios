//
//  SAMCPublicViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicViewController.h"

@interface SAMCPublicViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *customTableView;
@property (nonatomic, strong) UISearchDisplayController *customSearchResultController;
@property (nonatomic, strong) UISearchBar *customSearchBar;

@property (nonatomic, strong) UITableView *spTableView;

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
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.spTableView = nil;
    
    self.navigationItem.title = @"Public";
    
    self.customTableView = [[UITableView alloc] init];
    self.customTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.customTableView.backgroundColor = [UIColor greenColor];
    self.customTableView.dataSource = self;
    self.customTableView.delegate = self;
    self.customTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.customTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.customTableView];
    
    self.customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.customSearchBar.delegate = self;
    self.customSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.customTableView.tableHeaderView = self.customSearchBar;
    
    self.customSearchResultController = [[UISearchDisplayController alloc] initWithSearchBar:self.customSearchBar
                                                                          contentsController:self];
    self.customSearchResultController.delegate = self;
    self.customSearchResultController.searchResultsDataSource = self;
    self.customSearchResultController.searchResultsDelegate = self;
    
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomPublicCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
//    NSString *value = nil;
//    if (tableView == self.countryCodeTableView) {
//        NSString *key = self.indexArray[indexPath.section];
//        value = [[self.countryCodeDictionary objectForKey:key] objectAtIndex:indexPath.row];
//    } else {
//        value = [self.searchResultArray objectAtIndex:indexPath.row];
//    }
//    NSArray *splitValueList = [value componentsSeparatedByString:@","];
//    cell.textLabel.text = splitValueList[0];
//    cell.detailTextLabel.text = [splitValueList count] > 1 ? splitValueList[1]:@"";
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if ([self.indexArray[section] isEqualToString:@"#"]) {
//        return [self topHitTitle];
//    }
//    return self.indexArray[section];
//}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UISearchBarDelegate
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

@end
