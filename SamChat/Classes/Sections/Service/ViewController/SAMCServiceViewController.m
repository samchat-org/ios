//
//  SAMCServiceViewController.m
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServiceViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "SAMCNewRequestViewController.h"

@interface SAMCServiceViewController()

@property (nonatomic, strong) UITableView *requestTableView;
@property (nonatomic, strong) UIButton *requestButton;

@property (nonatomic, strong) UITableView *responseTableView;


@end

@implementation SAMCServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    // TODO: init according current mode
    [self setupCustomModeViews];
}

- (void)switchToUserMode:(NSNotification *)notification
{
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    NSLog(@"%ld", mode);
    if (mode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)setupCustomModeViews
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.responseTableView = nil;
    self.navigationItem.title = @"Request Service";
    
    self.requestButton = [[UIButton alloc] init];
    self.requestButton.backgroundColor = [UIColor grayColor];
    [self.requestButton.layer setCornerRadius:6.0f];
    self.requestButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.requestButton setTitle:@"+ Make a new service request" forState:UIControlStateNormal];
    [self.requestButton addTarget:self action:@selector(touchMakeNewRequest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.requestButton];
    
    self.requestTableView = [[UITableView alloc] init];
    self.requestTableView.backgroundColor = [UIColor greenColor];
    self.requestTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.requestTableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_requestButton]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_requestTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestTableView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_requestButton(44)]-20-[_requestTableView]|", SAMCTopBarHeight+20]
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_requestButton(44)]-20-[_requestTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton, _requestTableView)]];
}

- (void)setupSPModeViews
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.requestTableView = nil;
    self.requestButton = nil;
    self.navigationItem.title = @"Service Requests";
    
    self.responseTableView = [[UITableView alloc] init];
    self.responseTableView.backgroundColor = [UIColor yellowColor];
    self.responseTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.responseTableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_responseTableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_responseTableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_responseTableView]|"
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_responseTableView]|",SAMCTopBarHeight]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_responseTableView)]];
}

- (void)touchMakeNewRequest:(id)sender
{
    DDLogDebug(@"test");
    SAMCNewRequestViewController *vc = [[SAMCNewRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
