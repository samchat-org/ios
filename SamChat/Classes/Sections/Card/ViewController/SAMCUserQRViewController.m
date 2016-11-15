//
//  SAMCUserQRViewController.m
//  SamChat
//
//  Created by HJ on 10/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserQRViewController.h"
#import "SAMCQRScanner.h"
#import "SAMCAvatarImageView.h"

@interface SAMCUserQRViewController ()

@property (nonatomic, strong) SAMCAvatarImageView *avatarView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIImageView *qrImageView;
@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, assign) SAMCUserType userType;

@end

@implementation SAMCUserQRViewController

- (instancetype)initWithUser:(SAMCUser *)user userType:(SAMCUserType)userType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _user = user;
        _userType = userType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    if (_userType == SAMCuserTypeSamPros) {
        self.navigationItem.title = @"Service Provider QR Code";
    } else {
        self.navigationItem.title = @"Customer QR Code";
    }
    
    [self.view addSubview:self.shadowView];
    [self.view addSubview:self.avatarView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.categoryLabel];
    [self.view addSubview:self.qrImageView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_nameLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_categoryLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_categoryLabel)]];
    
    [_avatarView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_avatarView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0f
                                                             constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_avatarView(100)]-20-[_nameLabel][_categoryLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_avatarView,_nameLabel,_categoryLabel)]];
    
    [_shadowView addConstraint:[NSLayoutConstraint constraintWithItem:_shadowView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_shadowView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0f
                                                             constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_shadowView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_shadowView(100)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_shadowView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_qrImageView]-50-|"
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
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    NSString *avatarUrl = self.user.userInfo.avatar;
    NSURL *url = [avatarUrl length] ? [NSURL URLWithString:avatarUrl] : nil;
    [_avatarView samc_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_user"] options:SDWebImageRetryFailed];
    _nameLabel.text = self.user.userInfo.username;
    _categoryLabel.text = self.user.userInfo.spInfo.serviceCategory;
    _qrImageView.image = [self myQRCodeImage];
    
    if (_userType == SAMCUserTypeCustom) {
        _categoryLabel.hidden = YES;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_shadowView.bounds cornerRadius:_shadowView.bounds.size.height/2].CGPath;
}

- (UIImage *)myQRCodeImage
{
    UIImage *qrImage = [SAMCQRScanner createQRWithString:[NSString stringWithFormat:@"%@%@",SAMC_QR_ADDCONTACT_PREFIX, self.user.userId]
                                                  QRSize:CGSizeMake(300,300)
                                                 QRColor:SAMC_MAIN_DARKCOLOR
                                                 bkColor:SAMC_COLOR_LIGHTGREY];
    return qrImage;
}

#pragma mark - lazy load
- (SAMCAvatarImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[SAMCAvatarImageView alloc] initWithFrame:CGRectZero circleWidth:2.0f];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.circleColor = [UIColor whiteColor];
    }
    return _avatarView;
}

- (UIImageView *)qrImageView
{
    if (_qrImageView == nil) {
        _qrImageView = [[UIImageView alloc] init];
        _qrImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _qrImageView;
}

- (UIView *)shadowView
{
    if (_shadowView == nil) {
        _shadowView = [[UIView alloc] init];
        _shadowView.translatesAutoresizingMaskIntoConstraints = NO;
        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.layer.shadowColor = SAMC_MAIN_DARKCOLOR.CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
        _shadowView.layer.shadowOpacity = 0.5;
        _shadowView.layer.shadowRadius = 8;
    }
    return _shadowView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _nameLabel.textColor = UIColorFromRGB(0x13243F);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)categoryLabel
{
    if (_categoryLabel == nil) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _categoryLabel.font = [UIFont systemFontOfSize:15.0f];
        _categoryLabel.textColor = UIColorFromRGB(0x4F606D);
        _categoryLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _categoryLabel;
}

@end
