//
//  SAMCPublicSearchViewController.m
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSearchViewController.h"
#import "SAMCPublicManager.h"
#import "SAMCSPProfileViewController.h"
#import "UIView+Toast.h"

@interface SAMCPublicSearchViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITextField *searchKeyTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UITableView *searchResultTabeView;

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation SAMCPublicSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Public Search";
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    searchButton.backgroundColor = [UIColor grayColor];
    [searchButton addTarget:self action:@selector(onTouchSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    _searchKeyTextField = [[UITextField alloc] init];
    _searchKeyTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _searchKeyTextField.backgroundColor = UIColorFromRGB(0xF3F3F3);
    _searchKeyTextField.placeholder = @"Search by keywords, name, phone number...";
    _searchKeyTextField.rightView = searchButton;
    _searchKeyTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_searchKeyTextField];
    
    _locationTextField = [[UITextField alloc] init];
    _locationTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _locationTextField.backgroundColor = UIColorFromRGB(0xF3F3F3);
    _locationTextField.placeholder = @"Current Location";
    [self.view addSubview:_locationTextField];
    
    _searchResultTabeView = [[UITableView alloc] init];
    _searchResultTabeView.translatesAutoresizingMaskIntoConstraints = NO;
    _searchResultTabeView.backgroundColor = [UIColor greenColor];
    _searchResultTabeView.delegate = self;
    _searchResultTabeView.dataSource = self;
    [self.view addSubview:_searchResultTabeView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_searchKeyTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_searchKeyTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_locationTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_locationTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_searchResultTabeView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_searchResultTabeView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_searchKeyTextField(50)]-10-[_locationTextField(50)]-20-[_searchResultTabeView]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_searchKeyTextField,_locationTextField,_searchResultTabeView)]];
}

#pragma mark - Action
- (void)onTouchSearch:(id)sender
{
    NSString *key = self.searchKeyTextField.text;
    [self.data removeAllObjects];
    [self.searchResultTabeView reloadData];
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
            [wself.searchResultTabeView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SAMCUser *user = self.data[indexPath.row];
    cell.textLabel.text = user.userInfo.username;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SAMCSPProfileViewController *vc = [[SAMCSPProfileViewController alloc] init];
    vc.user = self.data[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
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
