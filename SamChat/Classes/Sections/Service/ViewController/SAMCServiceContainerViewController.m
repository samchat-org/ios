//
//  SAMCServiceContainerViewController.m
//  SamChat
//
//  Created by HJ on 10/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServiceContainerViewController.h"
#import "SAMCSPServiceViewController.h"
#import "SAMCCustomServiceViewController.h"

@interface SAMCServiceContainerViewController ()

@property (nonatomic, strong) SAMCCustomServiceViewController *customVC;
@property (nonatomic, strong) SAMCSPServiceViewController *spVC;

@end

@implementation SAMCServiceContainerViewController

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

- (void)setupCustomModeViews
{
    if (self.spVC) {
        [self hideContentController:self.spVC];
        self.spVC = nil;
    }
    self.customVC = [[SAMCCustomServiceViewController alloc] init];
    [self displayContentController:self.customVC];
}

- (void)setupSPModeViews
{
    if (self.customVC) {
        [self hideContentController:self.customVC];
        self.customVC = nil;
    }
    self.spVC = [[SAMCSPServiceViewController alloc] init];
    [self displayContentController:self.spVC];
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
