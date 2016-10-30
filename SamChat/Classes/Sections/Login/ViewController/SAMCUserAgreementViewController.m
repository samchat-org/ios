//
//  SAMCUserAgreementViewController.m
//  SamChat
//
//  Created by HJ on 10/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserAgreementViewController.h"

@interface SAMCUserAgreementViewController ()

//@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation SAMCUserAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.navigationItem.title = @"User Agreement";
    [self setupNavItem];
    
    _webView = [[UIWebView alloc] init];
    _webView.backgroundColor = SAMC_COLOR_LIGHTGREY;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_webView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_webView)]];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)setupNavItem
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"Done" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [rightBtn sizeToFit];
    [rightBtn setTitleColor:SAMC_COLOR_INK forState:UIControlStateNormal];
    UIBarButtonItem *navRightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, navRightItem];
}

- (void)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
