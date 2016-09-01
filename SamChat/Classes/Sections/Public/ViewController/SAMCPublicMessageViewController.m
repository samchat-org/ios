//
//  SAMCPublicMessageViewController.m
//  SamChat
//
//  Created by HJ on 9/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMessageViewController.h"

@implementation SAMCPublicMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor yellowColor];
}

@end
