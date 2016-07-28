//
//  SAMCPhoneCodeView.h
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAMCPhoneCodeView;

@protocol SAMCPhoneCodeViewDelegate <NSObject>

@optional
- (void)phonecodeDidChange:(SAMCPhoneCodeView *)view;
- (void)phonecodeCompleteInput:(SAMCPhoneCodeView *)view;
- (void)phonecodeBeginInput:(SAMCPhoneCodeView *)view;

@end

@interface SAMCPhoneCodeView : UIView<UIKeyInput>

@property (nonatomic, weak) id<SAMCPhoneCodeViewDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableString *phoneCode;

@end
