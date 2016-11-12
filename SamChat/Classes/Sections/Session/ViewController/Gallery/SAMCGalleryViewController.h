//
//  SAMCGalleryViewController.h
//  SamChat
//
//  Created by HJ on 11/12/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCGalleryItem : NSString
@property (nonatomic,copy)  NSString    *thumbPath;
@property (nonatomic,copy)  NSString    *imageURL;
@property (nonatomic,copy)  NSString    *name;
@end

@interface SAMCGalleryViewController : UIViewController

- (instancetype)initWithItem:(SAMCGalleryItem *)item;

@end
