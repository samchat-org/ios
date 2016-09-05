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
#import "SAMCContactManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"

@interface SAMCQRCodeScanViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) SAMCQRScanner *qrScanner;
@property (nonatomic, strong) SAMCQRScanView *qrScanView;

@property(nonatomic, strong) UIImage *scanImage;
@property(nonatomic, assign) BOOL isOpenFlash;

@property (nonatomic, strong) UILabel *topTitle;

@property (nonatomic, strong) UIView *bottomItemsView;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *myQRButton;

@end

@implementation SAMCQRCodeScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)setupSubviews
{
    _qrScanView = [[SAMCQRScanView alloc] init];
    _qrScanView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_qrScanView];
    
    _topTitle = [[UILabel alloc] init];
    _topTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _topTitle.textAlignment = NSTextAlignmentCenter;
    _topTitle.numberOfLines = 0;
    _topTitle.text = @"将取景框对准二维码即可自动扫描";
    _topTitle.textColor = [UIColor whiteColor];
    _topTitle.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topTitle];
    
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

    

    [self setupBottomItems];
}

- (void)setupBottomItems
{
    _bottomItemsView = [[UIView alloc] init];
    _bottomItemsView.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomItemsView.backgroundColor = [UIColor blackColor];
    _bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:_bottomItemsView];
    
    _photoButton = [[UIButton alloc] init];
    _photoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_photoButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_nor"] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateHighlighted];
    [_photoButton addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
    [_bottomItemsView addSubview:_photoButton];
    
    _flashButton = [[UIButton alloc] init];
    _flashButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_flashButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    [_bottomItemsView addSubview:_flashButton];
    
    _myQRButton = [[UIButton alloc] init];
    _myQRButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_myQRButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_myqrcode_nor"] forState:UIControlStateNormal];
    [_myQRButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_myqrcode_down"] forState:UIControlStateHighlighted];
    [_myQRButton addTarget:self action:@selector(myQRCode) forControlEvents:UIControlEventTouchUpInside];
    [_bottomItemsView addSubview:_myQRButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomItemsView(100)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_bottomItemsView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomItemsView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_bottomItemsView)]];
    [_bottomItemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_photoButton(65)]-10-[_flashButton(65)]-10-[_myQRButton(65)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_photoButton,_flashButton,_myQRButton)]];
    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_flashButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [_photoButton addConstraint:[NSLayoutConstraint constraintWithItem:_photoButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:87.0f]];
    [_flashButton addConstraint:[NSLayoutConstraint constraintWithItem:_flashButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:87.0f]];
    [_myQRButton addConstraint:[NSLayoutConstraint constraintWithItem:_myQRButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                             constant:87.0f]];
    
    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_photoButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_flashButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [_bottomItemsView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomItemsView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_myQRButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_qrScanView startDeviceReadyingWithText:@"相机启动中"];
    
    [self.view bringSubviewToFront:_topTitle];
    [self.view bringSubviewToFront:_bottomItemsView];
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
}

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_qrScanner stopScan];
    [_qrScanView stopScanAnimation];
}

- (void)openOrCloseFlash
{
    [_qrScanner openOrCloseFlash];
    
    self.isOpenFlash =!self.isOpenFlash;
    
    
    if (self.isOpenFlash) {
        [_flashButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"]
                   forState:UIControlStateNormal];
    } else {
        [_flashButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor"]
                   forState:UIControlStateNormal];
    }
}

- (void)openLocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
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
        
        [[SAMCContactManager sharedManager] queryAccurateUser:uniqueId completion:^(NSDictionary * _Nullable userDict, NSError * _Nullable error) {
            if (error) {
                [SVProgressHUD dismiss];
                NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
                [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
                [wself reStartDevice];
                return;
            }
            SAMCUserInfo *user = [SAMCUserInfo userInfoFromDict:userDict];
            [[SAMCContactManager sharedManager] addOrRemove:YES contact:user type:type completion:^(NSError * _Nullable error) {
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

@end
