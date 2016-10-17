//
//  SAMCQRCodeScanViewController.m
//  SamChat
//
//  Created by HJ on 8/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQRCodeScanViewController.h"
#import "SAMCQRScanner.h"
#import "SAMCQRScanView.h"
#import "UIAlertView+NTESBlock.h"
#import "SAMCMyQRCodeViewController.h"
#import "SAMCUserManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCCardPortraitView.h"
#import "SAMCAccountManager.h"

@interface SAMCQRCodeScanViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) SAMCQRScanner *qrScanner;
@property (nonatomic, strong) SAMCQRScanView *qrScanView;
@property (nonatomic, strong) UILabel *topTitle;

@property(nonatomic, strong) UIImage *scanImage;
//@property(nonatomic, assign) BOOL isOpenFlash;
//@property (nonatomic, strong) UIView *bottomItemsView;
//@property (nonatomic, strong) UIButton *photoButton;
//@property (nonatomic, strong) UIButton *flashButton;
//@property (nonatomic, strong) UIButton *myQRButton;

@property (nonatomic, strong) SAMCCardPortraitView *portraitView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *qrImageView;

@property (nonatomic, strong) UIBarButtonItem *uploadItem;

@end

@implementation SAMCQRCodeScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self stopScan];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [_qrScanView startDeviceReadyingWithText:@"starting..."];
        
        [self.view bringSubviewToFront:_topTitle];
//        [self.view bringSubviewToFront:_bottomItemsView];
        [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
    }
}

- (void)setupSubviews
{
    self.navigationItem.titleView = self.segmentedControl;
    [self setupQRScanView];
}

- (void)setupQRScanView
{
    self.navigationItem.rightBarButtonItem = self.uploadItem;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.qrScanView];
    [self.view addSubview:self.topTitle];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_qrScanView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_qrScanView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topTitle]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_topTitle)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_qrScanView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_qrScanView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topTitle(60)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_topTitle)]];
}

- (void)setupMyQRCodeView
{
    self.navigationItem.rightBarButtonItem = nil;
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    [self.view addSubview:self.portraitView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.qrImageView];
    
    SAMCUser *user = [SAMCAccountManager sharedManager].currentUser;
    _portraitView.avatarUrl = user.userInfo.avatar;
    _nameLabel.text = user.userInfo.username;
    UIImage *qrImage = [SAMCQRScanner createQRWithString:[NSString stringWithFormat:@"%@%@",SAMC_QR_ADDCONTACT_PREFIX, user.userId]
                                                  QRSize:CGSizeMake(300,300)
                                                 QRColor:SAMC_MAIN_DARKCOLOR
                                                 bkColor:SAMC_COLOR_LIGHTGREY];
    _qrImageView.image = qrImage;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_portraitView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portraitView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_nameLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_portraitView(100)][_nameLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portraitView,_nameLabel)]];
    
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
}

//- (void)setupBottomItems
//{
//    _bottomItemsView = [[UIView alloc] init];
//    _bottomItemsView.translatesAutoresizingMaskIntoConstraints = NO;
//    _bottomItemsView.backgroundColor = [UIColor blackColor];
//    _bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//    [self.view addSubview:_bottomItemsView];
//    
//    _photoButton = [[UIButton alloc] init];
//    _photoButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [_photoButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_nor"] forState:UIControlStateNormal];
//    [_photoButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateHighlighted];
//    [_photoButton addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomItemsView addSubview:_photoButton];
//    
//    _flashButton = [[UIButton alloc] init];
//    _flashButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [_flashButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
//    [_flashButton addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomItemsView addSubview:_flashButton];
//    
//    _myQRButton = [[UIButton alloc] init];
//    _myQRButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [_myQRButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_myqrcode_nor"] forState:UIControlStateNormal];
//    [_myQRButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_myqrcode_down"] forState:UIControlStateHighlighted];
//    [_myQRButton addTarget:self action:@selector(myQRCode) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomItemsView addSubview:_myQRButton];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomItemsView(100)]|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(_bottomItemsView)]];
//
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomItemsView]|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(_bottomItemsView)]];
//    [_bottomItemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_photoButton(65)]-10-[_flashButton(65)]-10-[_myQRButton(65)]"
//                                                                             options:0
//                                                                             metrics:nil
//                                                                               views:NSDictionaryOfVariableBindings(_photoButton,_flashButton,_myQRButton)]];
//    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
//                                                                 attribute:NSLayoutAttributeCenterX
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:_flashButton
//                                                                 attribute:NSLayoutAttributeCenterX
//                                                                multiplier:1.0f
//                                                                  constant:0.0f]];
//    [_photoButton addConstraint:[NSLayoutConstraint constraintWithItem:_photoButton
//                                                             attribute:NSLayoutAttributeHeight
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:nil
//                                                             attribute:NSLayoutAttributeNotAnAttribute
//                                                            multiplier:0.0f
//                                                              constant:87.0f]];
//    [_flashButton addConstraint:[NSLayoutConstraint constraintWithItem:_flashButton
//                                                             attribute:NSLayoutAttributeHeight
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:nil
//                                                             attribute:NSLayoutAttributeNotAnAttribute
//                                                            multiplier:0.0f
//                                                              constant:87.0f]];
//    [_myQRButton addConstraint:[NSLayoutConstraint constraintWithItem:_myQRButton
//                                                            attribute:NSLayoutAttributeHeight
//                                                            relatedBy:NSLayoutRelationEqual
//                                                               toItem:nil
//                                                            attribute:NSLayoutAttributeNotAnAttribute
//                                                           multiplier:0.0f
//                                                             constant:87.0f]];
//    
//    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:_photoButton
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                multiplier:1.0f
//                                                                  constant:0.0f]];
//    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:_flashButton
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                multiplier:1.0f
//                                                                  constant:0.0f]];
//    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:_myQRButton
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                multiplier:1.0f
//                                                                  constant:0.0f]];
//}



- (void)reStartDevice
{
    [_qrScanner startScan];
}

- (void)startScan
{
    if (![SAMCQRScanner isGetCameraPermission]) {
        [_qrScanView stopDeviceReadying];
        [self showError:@"   请到设置隐私中开启本程序相机权限   "];
        return;
    }
    
    if (!_qrScanner) {
        __weak __typeof(self) weakSelf = self;
        
        CGRect cropRect = CGRectZero;
        
        // 只识别区域内
        cropRect = [SAMCQRScanView getScanRectWithPreView:self.view];
        
        UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        videoView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:videoView atIndex:0];
        
        self.qrScanner = [[SAMCQRScanner alloc] initWithPreView:videoView
                                                       cropRect:cropRect
                                                     completion:^(NSArray<NSString *> *array){
                                                          [weakSelf scanResultWithArray:array];
                                                     }];
    }
    [_qrScanner startScan];
    
    [_qrScanView stopDeviceReadying];
    
    [_qrScanView startScanAnimation];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)stopScan
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_qrScanner) {
        [_qrScanner stopScan];
        [_qrScanView stopScanAnimation];
    }
}
//
//- (void)openOrCloseFlash
//{
//    [_qrScanner openOrCloseFlash];
//    
//    self.isOpenFlash =!self.isOpenFlash;
//    
//    
//    if (self.isOpenFlash) {
//        [_flashButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"]
//                   forState:UIControlStateNormal];
//    } else {
//        [_flashButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"]
//                   forState:UIControlStateNormal];
//    }
//}

- (void)openLocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (sender.selectedSegmentIndex == 0) {
        _portraitView = nil;
        _nameLabel = nil;
        _qrImageView = nil;
        [self setupQRScanView];
        
        [_qrScanView startDeviceReadyingWithText:@"starting..."];
        [self.view bringSubviewToFront:_topTitle];
        [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
    } else {
        [self stopScan];
        _qrScanView = nil;
        _topTitle = nil;
        _qrScanner = nil;
        [self setupMyQRCodeView];
    }
//    SAMCMyQRCodeViewController *vc = [[SAMCMyQRCodeViewController alloc] init];
//    [UIView beginAnimations:@"animation" context:nil];
//    [UIView setAnimationDuration:0.7];
//    [self.navigationController pushViewController:vc animated:NO];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
//    [UIView commitAnimations];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >=1)
    {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scanResult = feature.messageString;
        
        NSLog(@"%@",scanResult);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showError:(NSString*)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)scanResultWithArray:(NSArray<NSString *> *)array
{
    if (array.count < 1) {
        [self popAlertMsgWithScanResult:nil];
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    for (NSString *result in array) {
        NSLog(@"scanResult:%@",result);
    }
    
    NSString *strResult = array[0];
    
    if (!strResult) {
        [self popAlertMsgWithScanResult:nil];
        return;
    }
    
    [SAMCQRScanner systemVibrate];
    [self handleScanResult:strResult];
}

- (void)handleScanResult:(NSString *)strResult
{
#define SAMC_ADD_CONTACT_PREFIX @"SAMC_CONTACT:"
    SAMCContactListType type = SAMCContactListTypeServicer;
    if ([self currentUserMode] == SAMCUserModeTypeSP) {
        type = SAMCContactListTypeCustomer;
    }
    
    if ([strResult hasPrefix:SAMC_ADD_CONTACT_PREFIX]) {
        [SVProgressHUD showWithStatus:@"adding ..." maskType:SVProgressHUDMaskTypeBlack];
        strResult = [strResult substringFromIndex:[SAMC_ADD_CONTACT_PREFIX length]];
        NSNumber *uniqueId = @([strResult integerValue]);
        __weak typeof(self) wself = self;
        
        [[SAMCUserManager sharedManager] queryAccurateUser:uniqueId completion:^(NSDictionary * _Nullable userDict, NSError * _Nullable error) {
            if (error) {
                [SVProgressHUD dismiss];
                NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
                [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
                [wself reStartDevice];
                return;
            }
            SAMCUser *user = [SAMCUser userFromDict:userDict];
            [[SAMCUserManager sharedManager] addOrRemove:YES contact:user type:type completion:^(NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                NSString *toast;
                if (error) {
                    toast = error.userInfo[NSLocalizedDescriptionKey];
                } else {
                    toast = @"adding success";
                }
                [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
                [wself reStartDevice];
            }];
        }];
    } else {
        [self popAlertMsgWithScanResult:strResult];
    }
}

- (void)addContact:(NSNumber *)uniqueId
{
    if (uniqueId == nil) {
        return;
    }
    
}

- (void)popAlertMsgWithScanResult:(NSString*)strResult
{
    if (!strResult) {
        strResult = @"识别失败";
    }
    
    __weak __typeof(self) weakSelf = self;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"content"
                                                    message:strResult
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        [weakSelf reStartDevice];
    }];
}

- (void)openPhoto
{
    if ([SAMCQRScanner isGetPhotoPermission]) {
        [self openLocalPhoto];
    } else {
        [self showError:@"      请到设置->隐私中开启本程序相册权限     "];
    }
}

- (void)myQRCode
{
    SAMCMyQRCodeViewController *vc = [[SAMCMyQRCodeViewController alloc] init];
    vc.currentUserMode = self.currentUserMode;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy load
- (UISegmentedControl *)segmentedControl
{
    if (_segmentedControl == nil) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Scan",@"My QR Code"]];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.tintColor = SAMC_MAIN_DARKCOLOR;
        [_segmentedControl addTarget:self action:@selector(segmentedControlChanged:)forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (SAMCCardPortraitView *)portraitView
{
    if (_portraitView == nil) {
        _portraitView = [[SAMCCardPortraitView alloc] initWithFrame:CGRectZero effect:NO];
        _portraitView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _portraitView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.textColor = UIColorFromRGB(0x13243F);
        _nameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UIImageView *)qrImageView
{
    if (_qrImageView == nil) {
        _qrImageView = [[UIImageView alloc] init];
        _qrImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _qrImageView;
}

- (SAMCQRScanView *)qrScanView
{
    if (_qrScanView == nil) {
        _qrScanView = [[SAMCQRScanView alloc] init];
        _qrScanView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _qrScanView;
}

- (UILabel *)topTitle
{
    if (_topTitle == nil) {
        _topTitle = [[UILabel alloc] init];
        _topTitle.translatesAutoresizingMaskIntoConstraints = NO;
        _topTitle.textAlignment = NSTextAlignmentCenter;
        _topTitle.numberOfLines = 0;
        _topTitle.text = @"Place QR code at the center to scan";
        _topTitle.textColor = [UIColor whiteColor];
        _topTitle.backgroundColor = [UIColor clearColor];
    }
    return _topTitle;
}

- (UIBarButtonItem *)uploadItem
{
    if (_uploadItem == nil) {
        UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [uploadBtn addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
        //    [uploadBtn setImage:[UIImage imageNamed:@"icon_tinfo_normal"] forState:UIControlStateNormal];
        //    [uploadBtn setImage:[UIImage imageNamed:@"icon_tinfo_pressed"] forState:UIControlStateHighlighted];
        [uploadBtn setTitle:@"Upload" forState:UIControlStateNormal];
        [uploadBtn setTitleColor:SAMC_MAIN_DARKCOLOR forState:UIControlStateNormal];
        uploadBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        uploadBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [uploadBtn sizeToFit];
        _uploadItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    }
    return _uploadItem;
}

@end
