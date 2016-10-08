//
//  SAMCPhoneCodeView.m
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPhoneCodeView.h"

@interface SAMCPhoneCodeView ()

@property (nonatomic, strong) NSArray *codeViews;
@property (nonatomic, strong) NSArray *inputViews;
@property (nonatomic, strong) NSMutableString *phoneCode;

@end

@implementation SAMCPhoneCodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.phoneCode = [NSMutableString string];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.codeViews = @[[UIView new],[UIView new],[UIView new],[UIView new]];
    for (UIView *view in self.codeViews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor grayColor];
        [self addSubview:view];
    }
    NSDictionary *viewsDictionary = @{
                                      @"view1" : self.codeViews[0],
                                      @"view2" : self.codeViews[1],
                                      @"view3" : self.codeViews[2],
                                      @"view4" : self.codeViews[3],
                                      };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1]-20-[view2(==view1)]-20-[view3(==view1)]-20-[view4(==view1)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view1":self.codeViews[0]}]];
    
    for (UIView *view in self.codeViews) {
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }
    
    self.inputViews = @[[UIView new],[UIView new],[UIView new],[UIView new]];
    for (int i=0; i<4; i++) {
        UIView *view = self.inputViews[i];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor blackColor];
        view.hidden = YES;
        view.layer.cornerRadius = 10.0f;
        [self addSubview:view];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0f
                                                          constant:20.0f]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0f
                                                          constant:20.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.codeViews[i]
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.codeViews[i]
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }
}

- (BOOL)becomeFirstResponder
{
    if ([self.delegate respondsToSelector:@selector(phonecodeBeginInput:)]) {
        [self.delegate phonecodeBeginInput:self];
    }
    return [super becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIKeyInput
- (UIKeyboardType)keyboardType
{
//    return UIKeyboardTypeNumberPad;
    return UIKeyboardTypePhonePad;
}

- (BOOL)hasText
{
    return self.phoneCode.length > 0;
}

- (void)insertText:(NSString *)text
{
    if (self.phoneCode.length >= 4) {
        return;
    }
    if ([@"0123456789" rangeOfString:text].location != NSNotFound) {
        [self.inputViews[self.phoneCode.length] setHidden:NO];
        [self.phoneCode appendString:text];
        if ([self.delegate respondsToSelector:@selector(phonecodeDidChange:)]) {
            [self.delegate phonecodeDidChange:self];
        }
        if (self.phoneCode.length == 4) {
            if ([self.delegate respondsToSelector:@selector(phonecodeCompleteInput:)]) {
                [self.delegate phonecodeCompleteInput:self];
            }
        }
        [self setNeedsDisplay];
    }
}

- (void)deleteBackward
{
    if (self.phoneCode.length > 0) {
        [self.phoneCode deleteCharactersInRange:NSMakeRange(self.phoneCode.length-1, 1)];
        [self.inputViews[self.phoneCode.length] setHidden:YES];
        if ([self.delegate respondsToSelector:@selector(phonecodeDidChange:)]) {
            [self.delegate phonecodeDidChange:self];
        }
    }
    [self setNeedsDisplay];
}

#pragma mark - UIView
- (void)drawRect:(CGRect)rect
{
    for (UIView *view in self.codeViews) {
        view.layer.cornerRadius = view.frame.size.width/2;
    }
}
@end
