//
//  SAMCPublicInputView.h
//  SamChat
//
//  Created by HJ on 10/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCPublicInputView : UIView

@property (nonatomic, assign) NSInteger              maxTextLength;
@property (nonatomic, assign) CGFloat                inputBottomViewHeight;

@property (strong, nonatomic)  NIMInputToolBar *toolBar;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setInputDelegate:(id<NIMInputDelegate>)delegate;
- (void)setInputActionDelegate:(id<NIMInputActionDelegate>)actionDelegate;
- (void)setInputConfig:(id<NIMSessionConfig>)config;

- (void)setInputTextPlaceHolder:(NSString*)placeHolder;

@end
