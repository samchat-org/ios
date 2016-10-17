//
//  SAMCNewRequestViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCNewRequestViewController.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCQuestionManager.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "SAMCResourceManager.h"
#import "SAMCSelectLocationViewController.h"

@import CoreLocation;
@interface SAMCNewRequestViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) UILabel *requestLabel;
@property (nonatomic, strong) UITextField *requestTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) NSMutableDictionary *location;

@end

@implementation SAMCNewRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [[NSMutableArray alloc] init];
    [self setupSubviews];
    [self setUpNavItem];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
            [self.view makeToast:@"请在设置-隐私里允许程序使用地理位置服务"
                        duration:2
                        position:CSToastPositionCenter];
        }else{
            [_locationManager startUpdatingLocation];
        }
    }else{
        [self.view makeToast:@"请打开地理位置服务"
                    duration:2
                    position:CSToastPositionCenter];
    }
    
    [self queryPopularRequests];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.navigationItem.title = @"New Request";
    
    [self.view addSubview:self.requestLabel];
    [self.view addSubview:self.requestTextField];
    [self.view addSubview:self.locationTextField];
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_requestLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_requestTextField]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_locationTextField]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_locationTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_requestLabel(35)]-10-[_requestTextField(35)]-10-[_locationTextField(35)]-10-[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestLabel,_requestTextField,_locationTextField,_tableView)]];
}

- (void)setUpNavItem{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton addTarget:self action:@selector(sendRequest:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:SAMC_MAIN_DARKCOLOR forState:UIControlStateNormal];
    [sendButton sizeToFit];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = sendItem;
}

- (void)sendRequest:(UIButton *)sender
{
    DDLogDebug(@"sendRequest");
    NSString *question = self.requestTextField.text;
    if ((self.location == nil) && (self.currentLocation)) {
        self.location = [[NSMutableDictionary alloc] init];
        [self.location setObject:@{SAMC_LONGITUDE:@(self.currentLocation.coordinate.longitude),
                                   SAMC_LATITUDE:@(self.currentLocation.coordinate.latitude)} forKey:SAMC_LOCATION_INFO];
    }
    [SVProgressHUD showWithStatus:@"sending" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCQuestionManager sharedManager] sendQuestion:question location:self.location completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
            [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
            return;
        }
        [wself.navigationController popViewControllerAnimated:YES];
//        [wself.view makeToast:@"send request successful" duration:2.0f position:CSToastPositionCenter];
    }];
}

- (void)locationTextFieldEditingDidBegin:(id)sender
{
    SAMCSelectLocationViewController *vc = [[SAMCSelectLocationViewController alloc] init];
    __weak typeof(self) wself = self;
    vc.selectBlock = ^(NSDictionary *location, BOOL isCurrentLocation){
        if (isCurrentLocation) {
            wself.location = nil;
            wself.locationTextField.text = @"Current Location";
        } else {
            wself.location = [location mutableCopy];
            wself.locationTextField.text = location[SAMC_ADDRESS];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)queryPopularRequests
{
    __weak typeof(self) wself = self;
    [[SAMCQuestionManager sharedManager] queryPopularRequest:20 completion:^(NSArray<NSString *> * _Nullable populars) {
        DDLogDebug(@"tet:%@", populars);
        wself.data = [populars mutableCopy];
        [wself.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"popular requests";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCSPopularRequestCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.data[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x52626F);
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.requestTextField.text = self.data[indexPath.row];
    [self.requestTextField becomeFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    _currentLocation = [locations lastObject];
    DDLogDebug(@"location: %@", _currentLocation);
    [_locationManager stopUpdatingLocation];
}

#pragma mark - lazy load
- (UILabel *)requestLabel
{
    if (_requestLabel == nil) {
        _requestLabel = [[UILabel alloc] init];
        _requestLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _requestLabel.text = @"How can we help?";
        _requestLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _requestLabel.textColor = SAMC_MAIN_DARKCOLOR;
    }
    return _requestLabel;
}

- (UITextField *)requestTextField
{
    if (_requestTextField == nil) {
        _requestTextField = [[UITextField alloc] init];
        _requestTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _requestTextField.borderStyle = UITextBorderStyleNone;
        _requestTextField.backgroundColor = [UIColor whiteColor];
        _requestTextField.placeholder = @"What service do you need today?";
        _requestTextField.layer.cornerRadius = 6.0f;
        _requestTextField.font = [UIFont systemFontOfSize:15.0f];
        
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
        _requestTextField.leftView = leftLabel;
        _requestTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [rightView setImage:[UIImage imageNamed:@"service_edit"]];
        rightView.contentMode = UIViewContentModeScaleAspectFit;
        _requestTextField.rightView = rightView;
        _requestTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _requestTextField;
}

- (UITextField *)locationTextField
{
    if (_locationTextField == nil) {
        _locationTextField = [[UITextField alloc] init];
        _locationTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _locationTextField.borderStyle = UITextBorderStyleNone;
        _locationTextField.backgroundColor = [UIColor whiteColor];
        _locationTextField.placeholder = @"Current Location";
        _locationTextField.layer.cornerRadius = 6.0f;
        _locationTextField.font = [UIFont systemFontOfSize:15.0f];
        
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
        _locationTextField.leftView = leftLabel;
        _locationTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [rightView setImage:[UIImage imageNamed:@"service_location"]];
        rightView.contentMode = UIViewContentModeScaleAspectFit;
        _locationTextField.rightView = rightView;
        _locationTextField.rightViewMode = UITextFieldViewModeAlways;
        
        [_locationTextField addTarget:self action:@selector(locationTextFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    }
    return _locationTextField;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *view = (UIView *)[touch view];
    if ((view != self.requestTextField) && (view != self.locationTextField)) {
        [self.requestTextField resignFirstResponder];
        [self.locationTextField resignFirstResponder];
    }
}

@end
