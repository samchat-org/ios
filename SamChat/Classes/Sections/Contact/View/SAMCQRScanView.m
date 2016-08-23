//
//  SAMCQRScanView.m
//  SamChat
//
//  Created by HJ on 8/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQRScanView.h"
#import "SAMCQRScanLineView.h"

#define SAMCCenterUpOffset 44
#define SAMCXScanRetangleOffset 60

@interface SAMCQRScanView()

@property (nonatomic, assign) CGRect scanRetangleRect;
@property (nonatomic, strong) SAMCQRScanLineView *scanLineAnimation;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *labelReadying;

@end

@implementation SAMCQRScanView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self drawScanRect];
}

- (void)startDeviceReadyingWithText:(NSString*)text
{
    int XRetangleLeft = SAMCXScanRetangleOffset;
    int sizeWH = self.frame.size.width - XRetangleLeft * 2;
    
    CGSize sizeRetangle = CGSizeMake(sizeWH, sizeWH);
    
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = self.frame.size.height/2.0 - sizeRetangle.height/2.0 - SAMCCenterUpOffset;
    
    //设备启动状态提示
    if (!_activityView) {
        self.activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_activityView setCenter:CGPointMake(XRetangleLeft +  sizeRetangle.width/2 - 50, YMinRetangle + sizeRetangle.height/2)];
        
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_activityView];
        
        CGRect labelReadyRect = CGRectMake(_activityView.frame.origin.x + _activityView.frame.size.width + 10, _activityView.frame.origin.y, 100, 30);
        self.labelReadying = [[UILabel alloc]initWithFrame:labelReadyRect];
        _labelReadying.backgroundColor = [UIColor clearColor];
        _labelReadying.textColor  = [UIColor whiteColor];
        _labelReadying.font = [UIFont systemFontOfSize:18.];
        _labelReadying.text = text;
        
        [self addSubview:_labelReadying];
        
        [_activityView startAnimating];
    }
}

- (void)stopDeviceReadying
{
    if (_activityView) {
        
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        [_labelReadying removeFromSuperview];
        
        self.activityView = nil;
        self.labelReadying = nil;
    }
}

- (void)startScanAnimation
{
    UIImage *animationImage = [UIImage imageNamed:@"qrcode_scan_light_green"];
    if (!_scanLineAnimation) {
        self.scanLineAnimation = [[SAMCQRScanLineView alloc] init];
    }
    [_scanLineAnimation startAnimatingWithRect:_scanRetangleRect
                                        inView:self
                                         image:animationImage];
}

- (void)stopScanAnimation
{
    if (_scanLineAnimation) {
        [_scanLineAnimation stopAnimating];
    }
}


- (void)drawScanRect
{
    int XRetangleLeft = SAMCXScanRetangleOffset;
    int sizeWH = self.frame.size.width - XRetangleLeft * 2;
    CGSize sizeRetangle = CGSizeMake(sizeWH, sizeWH);
    
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = self.frame.size.height/2.0 - sizeRetangle.height/2.0 - SAMCCenterUpOffset;
    CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
    CGFloat XRetangleRight = self.frame.size.width - XRetangleLeft;
    
    NSLog(@"frame:%@",NSStringFromCGRect(self.frame));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //非扫码区域半透明
    {
        //设置非识别区域颜色
        CGContextSetRGBFillColor(context, 247.f/255.f,202.f/255.f,15.f/255.f, 0.2);
        
        //填充矩形
        //扫码区域上面填充
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, YMinRetangle);
        CGContextFillRect(context, rect);
        
        //扫码区域左边填充
        rect = CGRectMake(0, YMinRetangle, XRetangleLeft,sizeRetangle.height);
        CGContextFillRect(context, rect);
        
        //扫码区域右边填充
        rect = CGRectMake(XRetangleRight, YMinRetangle, XRetangleLeft,sizeRetangle.height);
        CGContextFillRect(context, rect);
        
        //扫码区域下面填充
        rect = CGRectMake(0, YMaxRetangle, self.frame.size.width,self.frame.size.height - YMaxRetangle);
        CGContextFillRect(context, rect);
        //执行绘画
        CGContextStrokePath(context);
    }
    
    //中间画矩形(正方形)
    UIColor *colorRetangleLine = [UIColor whiteColor];
    CGContextSetStrokeColorWithColor(context, colorRetangleLine.CGColor);
    CGContextSetLineWidth(context, 1);
    
    CGContextAddRect(context, CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height));
    
    //CGContextMoveToPoint(context, XRetangleLeft, YMinRetangle);
    //CGContextAddLineToPoint(context, XRetangleLeft+sizeRetangle.width, YMinRetangle);
    
    CGContextStrokePath(context);
    
    _scanRetangleRect = CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height);
    NSLog(@"_scanRetangleRect:%@",NSStringFromCGRect(_scanRetangleRect));
    
    //相框角的宽度和高度
    int wAngle = 24;
    int hAngle = 24;
    
    //4个角的 线的宽度
    CGFloat linewidthAngle = 4; // 经验参数：6和4
    
    //画扫码矩形以及周边半透明黑色坐标参数
    CGFloat diffAngle = 0.0f;
    //diffAngle = linewidthAngle / 2; //框外面4个角，与框有缝隙
    //diffAngle = linewidthAngle/2;  //框4个角 在线上加4个角效果
    //diffAngle = 0;//与矩形框重合
    
    diffAngle = linewidthAngle/3; //框外面4个角，与框紧密联系在一起
    
    UIColor *colorAngle = [UIColor colorWithRed:0. green:167./255. blue:231./255. alpha:1.0];
    CGContextSetStrokeColorWithColor(context, colorAngle.CGColor);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, linewidthAngle);
    
    //
    CGFloat leftX = XRetangleLeft - diffAngle;
    CGFloat topY = YMinRetangle - diffAngle;
    CGFloat rightX = XRetangleRight + diffAngle;
    CGFloat bottomY = YMaxRetangle + diffAngle;
    
    //左上角水平线
    CGContextMoveToPoint(context, leftX-linewidthAngle/2, topY);
    CGContextAddLineToPoint(context, leftX + wAngle, topY);
    
    //左上角垂直线
    CGContextMoveToPoint(context, leftX, topY-linewidthAngle/2);
    CGContextAddLineToPoint(context, leftX, topY+hAngle);
    
    //左下角水平线
    CGContextMoveToPoint(context, leftX-linewidthAngle/2, bottomY);
    CGContextAddLineToPoint(context, leftX + wAngle, bottomY);
    
    //左下角垂直线
    CGContextMoveToPoint(context, leftX, bottomY+linewidthAngle/2);
    CGContextAddLineToPoint(context, leftX, bottomY - hAngle);
    
    //右上角水平线
    CGContextMoveToPoint(context, rightX+linewidthAngle/2, topY);
    CGContextAddLineToPoint(context, rightX - wAngle, topY);
    
    //右上角垂直线
    CGContextMoveToPoint(context, rightX, topY-linewidthAngle/2);
    CGContextAddLineToPoint(context, rightX, topY + hAngle);
    
    //右下角水平线
    CGContextMoveToPoint(context, rightX+linewidthAngle/2, bottomY);
    CGContextAddLineToPoint(context, rightX - wAngle, bottomY);
    
    //右下角垂直线
    CGContextMoveToPoint(context, rightX, bottomY+linewidthAngle/2);
    CGContextAddLineToPoint(context, rightX, bottomY - hAngle);
    
    CGContextStrokePath(context);
}

//根据矩形区域，获取识别区域
+ (CGRect)getScanRectWithPreView:(UIView*)view
{
    int XRetangleLeft = SAMCXScanRetangleOffset;
    int sizeWH = view.frame.size.width - XRetangleLeft * 2;
    CGSize sizeRetangle = CGSizeMake(sizeWH, sizeWH);
    
    //扫码区域Y轴最小坐标
    CGFloat YMinRetangle = view.frame.size.height/2.0 - sizeRetangle.height/2.0 - SAMCCenterUpOffset;
    //扫码区域坐标
    CGRect cropRect =  CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height);
//    DDLogDebug(@"getScanRectWithPreView:%@",NSStringFromCGRect(cropRect));
    
    CGRect rectOfInterest;
    
    //ref:http://www.cocoachina.com/ios/20141225/10763.html
    CGSize size = view.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                    cropRect.origin.x/size.width,
                                    cropRect.size.height/fixHeight,
                                    cropRect.size.width/size.width);
        
        
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                    (cropRect.origin.x + fixPadding)/fixWidth,
                                    cropRect.size.height/size.height,
                                    cropRect.size.width/fixWidth);
        
        
    }
//    DDLogDebug(@"rectOfInterest:%@",NSStringFromCGRect(rectOfInterest));
    return rectOfInterest;
}


@end
