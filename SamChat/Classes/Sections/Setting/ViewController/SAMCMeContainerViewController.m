//
//  SAMCMeContainerViewController.m
//  SamChat
//
//  Created by HJ on 10/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMeContainerViewController.h"
#import "SAMCCustomMeViewController.h"
#import "SAMCSPMeViewController.h"

@interface SAMCMeContainerViewController ()

@property (nonatomic, strong) SAMCCustomMeViewController *customMeVC;
@property (nonatomic, strong) SAMCSPMeViewController *spMeVC;

@end

@implementation SAMCMeContainerViewController

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
    if (self.spMeVC) {
        [self hideContentController:self.spMeVC];
        self.spMeVC = nil;
    }
    self.customMeVC = [[SAMCCustomMeViewController alloc] init];
    [self displayContentController:self.customMeVC];
}

- (void)setupSPModeViews
{
    if (self.customMeVC) {
        [self hideContentController:self.customMeVC];
        self.customMeVC = nil;
    }
    self.spMeVC = [[SAMCSPMeViewController alloc] init];
    [self displayContentController:self.spMeVC];
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