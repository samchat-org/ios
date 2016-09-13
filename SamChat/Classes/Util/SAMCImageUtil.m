//
//  SAMCImageUtil.m
//  SamChat
//
//  Created by HJ on 9/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCImageUtil.h"

@implementation SAMCImageUtil

+ (UIImage *)scalingAndCroppingImage:(UIImage*)sourceImage ForSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
        scaleFactor = widthFactor; // scale to fit height
        else
        scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)scaleImage:(UIImage *)sourceImage toMaxSize:(NSInteger)maxsize
{
    UIImage *newImage = sourceImage;
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    CGFloat heightScale = newSize.height / maxsize;
    CGFloat widthScale = newSize.width / maxsize;
    
    if((heightScale>1.0) || (widthScale>1.0)){
        if(widthScale > heightScale){
            newSize = CGSizeMake(sourceImage.size.width / widthScale, sourceImage.size.height / widthScale);
        }else{
            newSize = CGSizeMake(sourceImage.size.width / heightScale, sourceImage.size.height / heightScale);
        }
        UIGraphicsBeginImageContext(newSize);
        [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
}

@end
