//
//  SAMCPublicContainerViewController.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicContainerViewController.h"
#import "SAMCPublicListViewController.h"
#import "SAMCPublicMessageViewController.h"
#import "SAMCPublicSession.h"

@interface SAMCPublicContainerViewController ()

@property (nonatomic, strong) SAMCPublicListViewController *pubicListVC;
@property (nonatomic, strong) SAMCPublicMessageViewController *publicMessageVC;

@end

@implementation SAMCPublicContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)switchToUserMode:(NSNotification *)notification
{
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    if (mode == SAMCUserModeTypeCustom) {
        [self setupCustomModeViews];
    } else {
        [self setupSPModeViews];
    }
}

- (void)setupCustomModeViews
{
    if (self.publicMessageVC) {
        [self hideContentController:self.publicMessageVC];
        self.publicMessageVC = nil;
    }
    self.pubicListVC = [[SAMCPublicListViewController alloc] init];
    [self displayContentController:self.pubicListVC];
}

- (void)setupSPModeViews
{
    if (self.pubicListVC) {
        [self hideContentController:self.pubicListVC];
        self.pubicListVC = nil;
    }
    self.publicMessageVC = [[SAMCPublicMessageViewController alloc] init];
    self.publicMessageVC.publicSession = [SAMCPublicSession sessionOfMyself];
    [self displayContentController:self.publicMessageVC];
}

- (void)displayContentController:(UIViewController*)content
{
    [self addChildViewController:content];
    [self.view addSubview:content.view];
    
    UIView *contentView = content.view;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(contentView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(contentView)]];
    [content didMoveToParentViewController:self];
}

- (void)hideContentController:(UIViewController*)content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

@end
