//
//  SAMCContactListViewController.m
//  SamChat
//
//  Created by HJ on 7/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCContactListViewController.h"

@interface SAMCContactListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchDisplayController *searchResultController;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SAMCContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    // TODO: init according user mode
    [self prepareCustomModeContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchResultController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                                    contentsController:self];
    self.searchResultController.delegate = self;
    self.searchResultController.searchResultsDataSource = self;
    self.searchResultController.searchResultsDelegate = self;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)switchToUserMode:(NSNotification *)notification
{
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    if (mode == SAMCUserModeTypeCustom) {
        [self prepareCustomModeContacts];
    } else {
        [self prepareSPModeContacts];
    }
}

- (void)prepareCustomModeContacts
{
    self.navigationItem.title = @"Service Provider";
    self.tableView.backgroundColor = [UIColor greenColor];
}

- (void)prepareSPModeContacts
{
    self.navigationItem.title = @"My Clients";
    self.tableView.backgroundColor = [UIColor yellowColor];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactListCellId";
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

@end
