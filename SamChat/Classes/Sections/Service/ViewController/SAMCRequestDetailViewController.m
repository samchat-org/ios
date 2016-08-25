//
//  SAMCRequestDetailViewController.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRequestDetailViewController.h"
#import "SAMCRequestDetailInfoView.h"

@interface SAMCRequestDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) SAMCRequestDetailInfoView *requestView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCRequestDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Request Details";
    _requestView = [[SAMCRequestDetailInfoView alloc] initWithQuestionSession:_questionSession];
    _requestView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_requestView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_requestView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_requestView][_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestView,_tableView)]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

@end
