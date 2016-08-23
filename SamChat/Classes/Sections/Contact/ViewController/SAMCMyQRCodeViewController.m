//
//  SAMCMyQRCodeViewController.m
//  SamChat
//
//  Created by HJ on 8/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMyQRCodeViewController.h"
#import "SAMCQRScanner.h"

@interface SAMCMyQRCodeViewController ()

@property (nonatomic, strong) UIImageView *qrImageView;

@end

@implementation SAMCMyQRCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"My QR Code";
    
    _qrImageView = [[UIImageView alloc] init];
    _qrImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_qrImageView setImage:[self myQRCodeImage]];
    [self.view addSubview:_qrImageView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[_qrImageView]-30-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_qrImageView)]];
    [_qrImageView addConstraint:[NSLayoutConstraint constraintWithItem:_qrImageView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_qrImageView
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0f
                                                              constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_qrImageView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (UIImage *)myQRCodeImage
{
    // TODO:
    UIImage *qrImage = [SAMCQRScanner createQRWithString:@"test" QRSize:CGSizeMake(300,300) QRColor:[UIColor blackColor] bkColor:[UIColor whiteColor]];
    return qrImage;
}

@end
