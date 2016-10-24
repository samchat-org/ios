//
//  SAMCPublicInputView.m
//  SamChat
//
//  Created by HJ on 10/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicInputView.h"
#import "UIView+NIM.h"
#import "NIMInputToolBar.h"
#import "UIImage+NIM.h"
#import "NIMUIConfig.h"
#import "NIMGlobalMacro.h"

@interface SAMCPublicInputView()<UITextViewDelegate>
{
    CGFloat   _inputTextViewOlderHeight;
}

@property (nonatomic, weak) id<NIMSessionConfig> inputConfig;
@property (nonatomic, weak) id<NIMInputDelegate> inputDelegate;
@property (nonatomic, weak) id<NIMInputActionDelegate> actionDelegate;

@end

@implementation SAMCPublicInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIComponents];
    }
    return self;
}

- (void)setInputConfig:(id<NIMSessionConfig>)config
{
    _inputConfig = config;
    
    //设置最大输入字数
    NSInteger textInputLength = 1000;
    if ([_inputConfig respondsToSelector:@selector(maxInputLength)]) {
        textInputLength = [_inputConfig maxInputLength];
    }
    self.maxTextLength = textInputLength;
    
    //设置placeholder
    if ([_inputConfig respondsToSelector:@selector(inputViewPlaceholder)]) {
        NSString *placeholder = [_inputConfig inputViewPlaceholder];
        _toolBar.inputTextView.placeHolder = placeholder;
    }
    //设置input bar 上的按钮
    if ([_inputConfig respondsToSelector:@selector(inputBarItemTypes)]) {
        NSArray *types = [_inputConfig inputBarItemTypes];
        [_toolBar setInputBarItemTypes:types];
    }
}

- (void)setInputDelegate:(id<NIMInputDelegate>)delegate
{
    _inputDelegate = delegate;
}

- (void)setInputActionDelegate:(id<NIMInputActionDelegate>)actionDelegate
{
    _actionDelegate                 = actionDelegate;
}

- (void)initUIComponents
{
    self.backgroundColor = [UIColor whiteColor];
    _toolBar = [[NIMInputToolBar alloc] initWithFrame:CGRectZero];
    [_toolBar.voiceBtn addTarget:self action:@selector(onTouchVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
    _toolBar.nim_size = [_toolBar sizeThatFits:CGSizeMake(self.nim_width, CGFLOAT_MAX)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_toolBar];
    _toolBar.inputTextView.delegate = self;
    
    [_toolBar.inputTextView setCustomUI];
    [_toolBar.inputTextView setPlaceHolder:@"Your message here"];
    _inputBottomViewHeight = 0;
    _inputTextViewOlderHeight = [NIMUIConfig topInputViewHeight];
    [_toolBar.recordButton setHidden:YES];
    [self updateVoiceBtnImages];
    [self addListenEvents];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _toolBar.inputTextView.delegate = nil;
}

#pragma mark - 外部接口
- (void)setInputTextPlaceHolder:(NSString*)placeHolder
{
    [_toolBar.inputTextView setPlaceHolder:placeHolder];
}

#pragma mark - private methods
- (void)addListenEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (CGFloat)getTextViewContentH:(UITextView *)textView
{
    return NIMKit_IOS8 ? textView.contentSize.height : ceilf([textView sizeThatFits:textView.frame.size].height);
}

- (void)updateVoiceBtnImages
{
    [_toolBar.voiceBtn setImage:[UIImage imageNamed:@"ico_photo"] forState:UIControlStateNormal];
    [_toolBar.voiceBtn setImage:[UIImage imageNamed:@"ico_photo"] forState:UIControlStateHighlighted];
}

#pragma mark - UIKeyboardNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if (!self.window) {
        return;//如果当前vc不是堆栈的top vc，则不需要监听
    }
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame   = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    BOOL ios7 = ([[[UIDevice currentDevice] systemVersion] doubleValue] < 8.0);
    //IOS7的横屏UIDevice的宽高不会发生改变，需要手动去调整
    if (ios7 && (orientation == UIDeviceOrientationLandscapeLeft
                 || orientation == UIDeviceOrientationLandscapeRight)) {
        toFrame.origin.y -= _inputBottomViewHeight;
        if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.width) {
            [self willShowBottomHeight:0];
        }else{
            [self willShowBottomHeight:toFrame.size.width];
        }
    }else{
        toFrame.origin.y -= _inputBottomViewHeight;
        if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
            [self willShowBottomHeight:0];
        }else{
            [self willShowBottomHeight:toFrame.size.height];
        }
    }
}

- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolBar.frame.size.height + bottomHeight- [NIMUIConfig topInputViewHeight];
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    if(bottomHeight == 0 && self.frame.size.height == self.toolBar.frame.size.height)
    {
        return;
    }
    self.frame = toFrame;
    
    if (bottomHeight == 0) {
        if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(hideInputView)]) {
            [self.inputDelegate hideInputView];
        }
    } else
    {
        if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(showInputView)]) {
            [self.inputDelegate showInputView];
        }
    }
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(inputViewSizeToHeight:showInputView:)]) {
        [self.inputDelegate inputViewSizeToHeight:toHeight showInputView:!(bottomHeight==0)];
    }
}

- (void)inputTextViewToHeight:(CGFloat)toHeight
{
    toHeight = MAX([NIMUIConfig topInputViewHeight], toHeight);
    toHeight = MIN([NIMUIConfig bottomInputViewHeight], toHeight);
    
    if (toHeight != _inputTextViewOlderHeight)
    {
        CGFloat changeHeight = toHeight - _inputTextViewOlderHeight;
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolBar.frame;
        rect.size.height += changeHeight;
        [self updateInputTopViewFrame:rect];
        
        if (self.toolBar.inputTextView.text.length) {
            [self.toolBar.inputTextView setContentOffset:CGPointMake(0.0f, (self.toolBar.inputTextView.contentSize.height - self.toolBar.inputTextView.frame.size.height)) animated:YES];
        }
        _inputTextViewOlderHeight = toHeight;
        
        if (_inputDelegate && [_inputDelegate respondsToSelector:@selector(inputViewSizeToHeight:showInputView:)]) {
            [_inputDelegate inputViewSizeToHeight:self.frame.size.height showInputView:YES];
        }
    }
}

- (void)updateInputTopViewFrame:(CGRect)rect
{
    self.toolBar.frame = rect;
    [self.toolBar layoutIfNeeded];
}

#pragma mark - button actions
- (BOOL)endEditing:(BOOL)force
{
    BOOL endEditing = [super endEditing:force];
    if (![self.toolBar.inputTextView isFirstResponder]) {
        _inputBottomViewHeight = 0.0;
        UIViewAnimationCurve curve = UIViewAnimationCurveEaseInOut;
        void(^animations)() = ^{
            [self willShowKeyboardFromFrame:CGRectZero toFrame:CGRectZero];
        };
        NSTimeInterval duration = 0.25;
        [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
    }
    return endEditing;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.actionDelegate respondsToSelector:@selector(onSendText:)] && [textView.text length] > 0) {
            [self.actionDelegate onSendText:textView.text];
            textView.text = @"";
            [textView layoutIfNeeded];
            [self inputTextViewToHeight:[self getTextViewContentH:textView]];;
        }
        return NO;
    }
    NSString *str = [textView.text stringByAppendingString:text];
    if (str.length > self.maxTextLength) {
        return NO;
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onTextChanged:)])
    {
        [self.actionDelegate onTextChanged:self];
    }
    [self inputTextViewToHeight:[self getTextViewContentH:textView]];
}


#pragma mark - InputEmoticonProtocol
- (void)didPressSend:(id)sender{
    if ([self.actionDelegate respondsToSelector:@selector(onSendText:)] && [self.toolBar.inputTextView.text length] > 0) {
        [self.actionDelegate onSendText:self.toolBar.inputTextView.text];
        self.toolBar.inputTextView.text = @"";
        [self inputTextViewToHeight:[self getTextViewContentH:self.toolBar.inputTextView]];;
    }
}

- (void)deleteTextRange: (NSRange)range
{
    NSString *text = [self.toolBar.inputTextView text];
    if (range.location + range.length <= [text length]
        && range.location != NSNotFound && range.length != 0)
    {
        NSString *newText = [text stringByReplacingCharactersInRange:range withString:@""];
        NSRange newSelectRange = NSMakeRange(range.location, 0);
        [self.toolBar.inputTextView setText:newText];
        [self.toolBar.inputTextView setSelectedRange:newSelectRange];
    }
}

- (void)onTouchVoiceBtn:(id)sender
{
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(onTapMediaItem:)]) {
        [_actionDelegate onTapMediaItem:[[_inputConfig mediaItems] firstObject]];
    }
}

@end