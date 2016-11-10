//
//  SAMCCustomServiceViewController.m
//  SamChat
//
//  Created by HJ on 10/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCustomServiceViewController.h"
#import "SAMCNewRequestViewController.h"
#import "SAMCQuestionManager.h"
#import "SAMCCustomRequestListCell.h"
#import "SAMCRequestDetailViewController.h"

@interface SAMCCustomServiceViewController()<SAMCQuestionManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *requestButton;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) UILabel *firstRequestTipLabel;
@property (nonatomic, strong) UILabel *firstRequestDetailLabel;
@property (nonatomic, strong) UIImageView *backgroundLogoImageView;
@property (nonatomic, strong) UIButton *firstRequestButton;

@end

@implementation SAMCCustomServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _data = [[NSMutableArray alloc] init];
    [self setupSubviews];
    [[SAMCQuestionManager sharedManager] addDelegate:self];
}

- (void)dealloc
{
    [[SAMCQuestionManager sharedManager] removeDelegate:self];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.parentViewController.navigationItem.title = @"Request Service";
    
    [self.data addObjectsFromArray:[[SAMCQuestionManager sharedManager] allSendQuestion]];
    [self sort];
    
    [self setupCustomModeEmptyRequestViews];
    [self setupCustomModeNotEmptyRequestViews];
}

- (void)setupCustomModeEmptyRequestViews
{
    [self.view addSubview:self.backgroundLogoImageView];
    [self.view addSubview:self.firstRequestTipLabel];
    [self.view addSubview:self.firstRequestDetailLabel];
    [self.view addSubview:self.firstRequestButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundLogoImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_backgroundLogoImageView(200)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_backgroundLogoImageView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_firstRequestTipLabel]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestTipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-48-[_firstRequestDetailLabel]-48-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestDetailLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_firstRequestButton]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_firstRequestTipLabel]-12-[_firstRequestDetailLabel]-20-[_firstRequestButton(40)]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_firstRequestTipLabel,_firstRequestDetailLabel,_firstRequestButton)]];
    if ([self.data count]) {
        [self hideCustomEmptyRequestView:YES];
    }
}

- (void)setupCustomModeNotEmptyRequestViews
{
    [self.view addSubview:self.requestButton];
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[_requestButton]-32-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_requestButton(40)]-20-[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_requestButton, _tableView)]];
    
    if (![self.data count]) {
        [self hideCustomNotEmptyRequestView:YES];
    }
}

- (void)hideCustomEmptyRequestView:(BOOL)hidden
{
    self.backgroundLogoImageView.hidden = hidden;
    self.firstRequestTipLabel.hidden = hidden;
    self.firstRequestDetailLabel.hidden = hidden;
    self.firstRequestButton.hidden = hidden;
}

- (void)hideCustomNotEmptyRequestView:(BOOL)hidden
{
    self.tableView.hidden = hidden;
    self.requestButton.hidden = hidden;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCCustomRequestListCellId";
    SAMCCustomRequestListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCCustomRequestListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SAMCQuestionSession *session = [self data][indexPath.row];
    [cell updateWithSession:session];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SAMCRequestDetailViewController *vc = [[SAMCRequestDetailViewController alloc] init];
    SAMCQuestionSession *session = [self data][indexPath.row];
    vc.questionSession = session;
    [[SAMCQuestionManager sharedManager] clearSendQuestionNewResponseCount:session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAMCQuestionSession *session = [self data][indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[SAMCQuestionManager sharedManager] deleteSendQuestion:session];
        [[self data] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (![[self data] count]) {
            [self reload];
        }
    }
}

#pragma mark - SAMCQuestionManagerDelegate
- (void)didAddQuestionSession:(SAMCQuestionSession *)questionSession
{
    if (questionSession.type != SAMCQuestionSessionTypeSend) {
        return;
    }
    [self.data addObject:questionSession];
    [self sort];
    [self reload];
}

- (void)didUpdateQuestionSession:(SAMCQuestionSession *)questionSession
{
    if (questionSession.type != SAMCQuestionSessionTypeSend) {
        return;
    }
    for (SAMCQuestionSession *session in self.data) {
        if (questionSession.questionId == session.questionId) {
            [self.data removeObject:session];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:questionSession];
    [self.data insertObject:questionSession atIndex:insert];
    [self.tableView reloadData];
}

#pragma mark - Private
- (NSInteger)findInsertPlace:(SAMCQuestionSession *)questionSession
{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SAMCQuestionSession *item = obj;
        if (item.lastResponseTime <= questionSession.lastResponseTime) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.data.count;
    }
}

- (void)sort
{
    [self.data sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SAMCQuestionSession *item1 = obj1;
        SAMCQuestionSession *item2 = obj2;
        if (item1.lastResponseTime < item2.lastResponseTime) {
            return NSOrderedDescending;
        }
        if (item1.lastResponseTime > item2.lastResponseTime) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)reload
{
    if ([self.data count]) {
        [self hideCustomNotEmptyRequestView:NO];
        [self hideCustomEmptyRequestView:YES];
        [self.tableView reloadData];
    } else {
        [self hideCustomNotEmptyRequestView:YES];
        [self hideCustomEmptyRequestView:NO];
    }
}

#pragma mark - Action
- (void)touchMakeNewRequest:(id)sender
{
    SAMCNewRequestViewController *vc = [[SAMCNewRequestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy load
- (UILabel *)firstRequestTipLabel
{
    if (_firstRequestTipLabel == nil) {
        _firstRequestTipLabel = [[UILabel alloc] init];
        _firstRequestTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _firstRequestTipLabel.font = [UIFont systemFontOfSize:19.0f];
        _firstRequestTipLabel.textColor = SAMC_COLOR_INK;
        _firstRequestTipLabel.text = @"Make your first request";
        _firstRequestTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _firstRequestTipLabel;
}

- (UILabel *)firstRequestDetailLabel
{
    if (_firstRequestDetailLabel == nil) {
        _firstRequestDetailLabel = [[UILabel alloc] init];
        _firstRequestDetailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _firstRequestDetailLabel.font = [UIFont systemFontOfSize:15.0f];
        _firstRequestDetailLabel.text = @"Tell us what professional services do you need or what job do you need done. Get started now!";
        _firstRequestDetailLabel.numberOfLines = 0;
        _firstRequestDetailLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        _firstRequestDetailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _firstRequestDetailLabel;
}

- (UIImageView *)backgroundLogoImageView
{
    if (_backgroundLogoImageView == nil) {
        _backgroundLogoImageView = [[UIImageView alloc] init];
        _backgroundLogoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_backgroundLogoImageView setImage:[UIImage imageNamed:@"service_bg_logo"]];
        _backgroundLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backgroundLogoImageView;
}

- (UIButton *)firstRequestButton
{
    if (_firstRequestButton == nil) {
        _firstRequestButton = [[UIButton alloc] init];
        _firstRequestButton.translatesAutoresizingMaskIntoConstraints = NO;
        _firstRequestButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_firstRequestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_firstRequestButton setTitle:@"Make a New Request" forState:UIControlStateNormal];
        _firstRequestButton.layer.cornerRadius = 20.0f;
        _firstRequestButton.layer.masksToBounds = YES;
        [_firstRequestButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_firstRequestButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_firstRequestButton addTarget:self action:@selector(touchMakeNewRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstRequestButton;
}

- (UIButton *)requestButton
{
    if (_requestButton == nil) {
        _requestButton = [[UIButton alloc] init];
        _requestButton.translatesAutoresizingMaskIntoConstraints = NO;
        _requestButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_requestButton setTitle:@"New Request" forState:UIControlStateNormal];
        _requestButton.layer.cornerRadius = 20.0f;
        _requestButton.layer.masksToBounds = YES;
        [_requestButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_active"] forState:UIControlStateNormal];
        [_requestButton setBackgroundImage:[UIImage imageNamed:@"ico_bkg_green_pressed"] forState:UIControlStateHighlighted];
        [_requestButton addTarget:self action:@selector(touchMakeNewRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _requestButton;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.estimatedRowHeight = 100;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

@end
