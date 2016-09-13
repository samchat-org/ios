//
//  SAMCImageUtil.h
//  SamChat
//
//  Created by HJ on 9/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>

@interface SAMCImageUtil : NSObject

+ (UIImage *)scalingAndCroppingImage:(UIImage*)sourceImage ForSize:(CGSize)targetSize;
+ (UIImage *)scaleImage:(UIImage *)sourceImage toMaxSize:(NSInteger)maxsize;

@end
