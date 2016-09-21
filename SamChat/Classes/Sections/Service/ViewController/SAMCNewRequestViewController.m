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

@interface SAMCNewRequestViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UILabel *requestLabel;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UITextField *requestTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) SAMCPlaceInfo *selectedPlaceInfo;

@end

@implementation SAMCNewRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [[NSMutableArray alloc] init];
    // TODO: init default selected place info
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"New Request";
    
    self.requestLabel = [[UILabel alloc] init];
    self.requestLabel.text = @"Your Request";
    self.requestLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.requestLabel];
    
    self.sendButton = [[UIButton alloc] init];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor greenColor];
    self.sendButton.layer.cornerRadius = 6.0f;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sendButton addTarget:self action:@selector(sendRequest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    self.requestTextField = [[UITextField alloc] init];
    self.requestTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.requestTextField.backgroundColor = [UIColor lightGrayColor];
    self.requestTextField.placeholder = @"What do you need help with today?";
//    self.requestTextField.layer.cornerRadius = 6.0f;
    self.requestTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.requestTextField];
    
    self.locationTextField = [[UITextField alloc] init];
    self.locationTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.locationTextField.backgroundColor = [UIColor lightGrayColor];
    self.locationTextField.placeholder = @"Current location";
//    self.locationTextField.layer.cornerRadius = 6.0f;
    self.locationTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.locationTextField addTarget:self action:@selector(locationTextFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.locationTextField];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor yellowColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestLabel][_sendButton(120)]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestLabel,_sendButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.requestLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_locationTextField]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_locationTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_tableView]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
//    NSString *visualFomat = [NSString stringWithFormat:@"V:|-%f-[_requestLabel(40)]-10-[_requestTextField(50)]-10-[_locationTextField(50)]-20-[_tableView]|", SAMCTopBarHeight+10];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_requestLabel(40)]-10-[_requestTextField(50)]-10-[_locationTextField(50)]-20-[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestLabel,_requestTextField,_locationTextField,_tableView)]];
}

- (void)sendRequest:(UIButton *)sender
{
    DDLogDebug(@"sendRequest");
    NSString *question = self.requestTextField.text;
    NSDictionary *location = @{SAMC_ADDRESS:self.locationTextField.text}; // TODO: change to real one
    [SVProgressHUD showWithStatus:@"sending" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCQuestionManager sharedManager] sendQuestion:question location:location completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
            [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
            return;
        }
        [wself.view makeToast:@"send request successful" duration:2.0f position:CSToastPositionCenter];
    }];
}

- (void)locationTextFieldDidChanged:(id)sender
{
    NSString *key = self.locationTextField.text;
    if ([key length] <= 0) {
        // TODO: clear ui
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(getPlacesInfo:) withObject:key afterDelay:0.5];
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
    SAMCPlaceInfo *placeInfo = self.data[indexPath.row];
    cell.textLabel.text = placeInfo.desc;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedPlaceInfo = self.data[indexPath.row];
    self.locationTextField.text = self.selectedPlaceInfo.desc;
    [self.data removeAllObjects];
    [self.tableView reloadData];
    [self.requestTextField becomeFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
