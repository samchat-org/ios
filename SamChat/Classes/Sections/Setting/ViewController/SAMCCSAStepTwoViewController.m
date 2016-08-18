//
//  SAMCCSAStepTwoViewController.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepTwoViewController.h"

@interface SAMCCSAStepTwoViewController ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *locationTextField;

@end

@implementation SAMCCSAStepTwoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    [self.navigationItem setTitle:@"Create Service Account"];
}

@end
