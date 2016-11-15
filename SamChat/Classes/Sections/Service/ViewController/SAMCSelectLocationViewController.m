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
#import "SAMCSearchBar.h"

@interface SAMCSelectLocationViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) SAMCSearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) NSInteger fixCellCount;
@property (nonatomic, assign) BOOL hideCurrentLocation;
@property (nonatomic, assign) SAMCUserModeType userMode;

@end

@implementation SAMCSelectLocationViewController

- (instancetype)initWithHideCurrentLocation:(BOOL)hidden userMode:(SAMCUserModeType)userMode
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _hideCurrentLocation = hidden;
        _userMode = userMode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fixCellCount = _hideCurrentLocation ? 0 : 1;
    self.data = [[NSMutableArray alloc] init];
    [self setupSubviews];
    [self setupNavItem];
    [self.searchBar becomeFirstResponder];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    
    _searchBar = [[SAMCSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"Find a location";
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    UIEdgeInsets separatorInset   = _tableView.separatorInset;
    separatorInset.right          = 0;
    _tableView.separatorInset = separatorInset;
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
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    UIColor *activeColor;
    UIColor *pressedColor;
    if (_userMode == SAMCUserModeTypeCustom) {
        activeColor = SAMC_COLOR_INGRABLUE;
        pressedColor = UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5f);
    } else {
        activeColor = [UIColor whiteColor];
        pressedColor = UIColorFromRGBA(0xFFFFFF, 0.5);
    }
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:activeColor forState:UIControlStateNormal];
    [doneButton setTitleColor:pressedColor forState:UIControlStateHighlighted];
    [doneButton sizeToFit];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneItem;
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

- (void)done:(id)sender
{
    if (self.selectBlock != nil) {
        NSDictionary *location = @{SAMC_ADDRESS:self.searchBar.text};
        self.selectBlock(location, NO);
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
    return [self.data count] + self.fixCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCSLocationCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.textColor = SAMC_COLOR_INK;
    if (self.fixCellCount && indexPath.row == 0) {
        cell.textLabel.text = @"CurrentLocation";
        cell.imageView.image = [UIImage imageNamed:@"service_location"];
    } else {
        SAMCPlaceInfo *placeInfo = self.data[indexPath.row-self.fixCellCount];
        cell.textLabel.text = placeInfo.desc;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.fixCellCount && indexPath.row == 0) {
        if (self.selectBlock != nil) {
            self.selectBlock(nil, YES);
        }
    } else {
        if (self.selectBlock != nil) {
            NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
            SAMCPlaceInfo *info = self.data[indexPath.row-self.fixCellCount];
            [location setObject:info.desc forKey:SAMC_ADDRESS];
            [location setObject:info.placeId forKey:SAMC_PLACE_ID];
        
            self.selectBlock(location, NO);
            self.selectBlock = nil;
        }
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
