//
//  SAMCQRScanner.m
//  SamChat
//
//  Created by HJ on 8/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQRScanner.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface SAMCQRScanner()<AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL bNeedScanResult;
}

@property (assign, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic, strong) NSMutableArray<NSString *> *arrayResult;

@property (nonatomic,weak) UIView *videoPreView;

@property(nonatomic,copy)void (^blockScanResult)(NSArray<NSString *> *array);

@end


@implementation SAMCQRScanner


- (instancetype)initWithPreView:(UIView*)preView
                       cropRect:(CGRect)cropRect
                     completion:(void (^)(NSArray<NSString *> *))completion
{
    if (self = [super init])
    {
        CGRect frame = preView.frame;
        frame.origin = CGPointZero;
        [self initParaWithPreView:preView cropRect:cropRect completion:completion];
    }
    return self;
}


- (void)initParaWithPreView:(UIView*)videoPreView
                   cropRect:(CGRect)cropRect
                 completion:(void(^)(NSArray<NSString *> *))completion
{
    self.blockScanResult = completion;
    self.videoPreView = videoPreView;
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!_device) {
        return;
    }
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if (!_input ) {
        return ;
    }
    
    bNeedScanResult = YES;
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _output.rectOfInterest = cropRect;
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGRect frame = videoPreView.frame;
    frame.origin = CGPointZero;
    _preview.frame = frame;
    
    [videoPreView.layer insertSublayer:self.preview atIndex:0];
    
    //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if (_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [_input.device lockForConfiguration:nil];
        [_input.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [_input.device unlockForConfiguration];
    }
}

- (void)startScan
{
    if (_input && !_session.isRunning) {
        [_session startRunning];
        bNeedScanResult = YES;
        
        [_videoPreView.layer insertSublayer:self.preview atIndex:0];
    }
}

- (void)stopScan
{
    if ( _input && _session.isRunning ) {
        bNeedScanResult = NO;
        [_session stopRunning];
    }
}

- (void)openFlash:(BOOL)bOpen
{
    AVCaptureDevice *device =  [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]) {
        [self.input.device lockForConfiguration:nil];
        self.input.device.torchMode = bOpen ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [self.input.device unlockForConfiguration];
    }
}

- (void)openOrCloseFlash
{
    AVCaptureDevice *device =  [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && [device hasFlash]) {
        AVCaptureTorchMode torch = self.input.device.torchMode;
        
        switch (_input.device.torchMode) {
            case AVCaptureTorchModeAuto:
                break;
            case AVCaptureTorchModeOff:
                torch = AVCaptureTorchModeOn;
                break;
            case AVCaptureTorchModeOn:
                torch = AVCaptureTorchModeOff;
                break;
            default:
                break;
        }
        
        [_input.device lockForConfiguration:nil];
        _input.device.torchMode = torch;
        [_input.device unlockForConfiguration];
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if (!bNeedScanResult) {
        return;
    }
    
    if (!_arrayResult) {
        self.arrayResult = [[NSMutableArray alloc] init];
    } else {
        [_arrayResult removeAllObjects];
    }
    
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            bNeedScanResult = NO;
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            [_arrayResult addObject:scannedResult];
        }
    }
    
    [self stopScan];
    
    if (_blockScanResult) {
        _blockScanResult(_arrayResult);
    }
}

+ (void)systemVibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (BOOL)isGetCameraPermission
{
    BOOL isCameraValid = YES;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        isCameraValid = NO;
    }
    return isCameraValid;
}


+ (BOOL)isGetPhotoPermission
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        
        if ( author == ALAuthorizationStatusDenied ) {
            
            return NO;
        }
        return YES;
    }
    
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if ( authorStatus == PHAuthorizationStatusDenied ) {
        
        return NO;
    }
    return YES;
}

#pragma mark - QRCodeGenerator
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor
{
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:qrColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:bkColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

@end
