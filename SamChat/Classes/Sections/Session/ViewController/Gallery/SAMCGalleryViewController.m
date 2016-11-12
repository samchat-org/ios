//
//  SAMCGalleryViewController.m
//  SamChat
//
//  Created by HJ on 11/12/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCGalleryViewController.h"
#import "UIImageView+WebCache.h"

@implementation SAMCGalleryItem
@end

@interface SAMCGalleryViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) SAMCGalleryItem *currentItem;

@end

@implementation SAMCGalleryViewController

- (instancetype)initWithItem:(SAMCGalleryItem *)item
{
    if (self = [super init]) {
        _currentItem = item;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat barHeight = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-barHeight)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.backgroundColor = SAMC_COLOR_LIGHTGREY;
    _scrollView.maximumZoomScale = 5.0f;
    [_scrollView addSubview:_imageView];
    [self.view addSubview:_scrollView];
    _scrollView.delegate = self;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_scrollView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_scrollView)]];
    
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSURL *url = [NSURL URLWithString:_currentItem.imageURL];
    [_imageView sd_setImageWithURL:url
                         placeholderImage:[UIImage imageWithContentsOfFile:_currentItem.thumbPath]
                                  options:SDWebImageRetryFailed];
    
    self.navigationItem.title = [_currentItem.name length] ? _currentItem.name : @"Photo";
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
