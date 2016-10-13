//
//  SAMCSelectLocationViewController.m
//  SamChat
//
//  Created by HJ on 10/12/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSelectLocationViewController.h"
#import "SAMCResourceManager.h"
#import "SAMCPlaceInfo.h"
#import "SAMCServerAPIMacro.h"

@interface SAMCSelectLocationViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SAMCSelectLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.data = [[NSMutableArray alloc] init];
    [self setupSubviews];
    [self setupNavItem];
    [self.searchBar becomeFirstResponder];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_MAIN_BACKGROUNDCOLOR;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"Find a location";
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = UIColorFromRGB(0xF9F9F9);
    _searchBar.delegate = self;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    for (UIView* subview in [[_searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField*)subview;
            [textField setBackgroundColor:SAMC_MAIN_BACKGROUNDCOLOR];
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.tableHeaderView = self.searchBar;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)setupNavItem
{
    self.navigationItem.title = @"Select Location";
    [self.navigationItem setHidesBackButton:YES];
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationButton addTarget:self action:@selector(onSelectCurrentLocation:) forControlEvents:UIControlEventTouchUpInside];
    [locationButton setImage:[UIImage imageNamed:@"btn_location_normal"] forState:UIControlStateNormal];
    [locationButton sizeToFit];
    UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithCustomView:locationButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,locationItem];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColorFromRGB(0x63839D) forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

#pragma mark - Action
- (void)findLocation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *key = self.searchBar.text;
    if ([key length] <= 0) {
        return;
    }
    [self performSelector:@selector(getPlacesInfo:) withObject:key afterDelay:0.5];
}

- (void)onSelectCurrentLocation:(id)sender
{
    if (self.selectBlock != nil) {
        self.selectBlock(nil, YES);
        self.selectBlock = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onCancel:(id)sender
{
    if (self.selectBlock != nil) {
        self.selectBlock = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getPlacesInfo:(NSString *)key
{
    DDLogDebug(@"getPlacesInfo: %@", key);
    __weak typeof(self) wself = self;
    [[SAMCResourceManager sharedManager] getPlacesInfo:key completion:^(NSArray<SAMCPlaceInfo *> *places, NSError *error) {
        DDLogDebug(@"places info: %@", places);
        [wself.data removeAllObjects];
        [wself.data addObjectsFromArray:places];
        [wself.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCSLocationCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x13243F);
    SAMCPlaceInfo *placeInfo = self.data[indexPath.row];
    cell.textLabel.text = placeInfo.desc;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    SAMCPlaceInfo *info = self.data[indexPath.row];
    [location setObject:info.desc forKey:SAMC_ADDRESS];
    [location setObject:info.placeId forKey:SAMC_PLACE_ID];
    
    if (self.selectBlock != nil) {
        self.selectBlock(location, NO);
        self.selectBlock = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self findLocation];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.data removeAllObjects];
    [self.tableView reloadData];
    [self findLocation];
}

@end