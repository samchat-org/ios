//
//  SAMCPublicSearchViewController.m
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicSearchViewController.h"

@interface SAMCPublicSearchViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITextField *searchKeyTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UITableView *searchResultTabeView;

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
    DDLogDebug(@"search");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
//    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = @"test";
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


@end
