//
//  SAMCCSAStepThreeViewController.m
//  SamChat
//
//  Created by HJ on 10/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepThreeViewController.h"
#import "SAMCTextView.h"
#import "SAMCServerAPIMacro.h"
#import "SVProgressHUD.h"
#import "SAMCSettingManager.h"
#import "UIView+Toast.h"
#import "SAMCCSADoneViewController.h"

@interface SAMCCSAStepThreeViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIImageView *stepImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) SAMCTextView *descriptionTextView;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) NSLayoutConstraint *doneButtonBottomContraint;

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@end

@implementation SAMCCSAStepThreeViewController

- (instancetype)initWithInformation:(NSMutableDictionary *)information
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _samProsInformation = information;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.descriptionTextView becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSubviews
{
    [self.navigationItem setTitle:@"Create Service Profile"];
    self.view.backgroundColor = SAMC_MAIN_BACKGROUNDCOLOR;
    [self setUpNavItem];
    
    [self.view addSubview:self.stepImageView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.descriptionTextView];
    [self.view addSubview:self.skipButton];
    [self.view addSubview:self.doneButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stepImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_tipLabel]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_descriptionTextView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_descriptionTextView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_stepImageView(16)]-10-[_tipLabel]-20-[_descriptionTextView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_stepImageView,_tipLabel,_descriptionTextView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_skipButton]-10-[_doneButton(==_skipButton)]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_skipButton,_doneButton)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_skipButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_doneButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    self.doneButtonBottomContraint = [NSLayoutConstraint constraintWithItem:_doneButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:-20.0f];
    [self.view addConstraint:self.doneButtonBottomContraint];
}

- (void)setUpNavItem{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:SAMC_MAIN_DARKCOLOR forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

- (void)onCancel
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onDone:(id)sender
{
    NSString *serviceDesc = _descriptionTextView.text;
    [self.samProsInformation setObject:serviceDesc forKey:SAMC_SERVICE_DESCRIPTION];
    
    [SVProgressHUD showWithStatus:@"Creating" maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCSettingManager sharedManager] createSamPros:self.samProsInformation completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            return;
        }
        SAMCCSADoneViewController *vc = [[SAMCCSADoneViewController alloc] init];
        [wself.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - UIKeyBoard Notification
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.doneButtonBottomContraint setConstant:-keyboardHeight-5];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.doneButtonBottomContraint setConstant:-20];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ([_descriptionTextView.text length]) {
        _doneButton.backgroundColor = UIColorFromRGB(0x2676B6);
        _doneButton.enabled = YES;
    } else {
        _doneButton.backgroundColor = UIColorFromRGB(0x88B1D2);
        _doneButton.enabled = NO;
    }
}

#pragma mark - lazy load
- (UIImageView *)stepImageView
{
    if (_stepImageView == nil) {
        _stepImageView = [[UIImageView alloc] init];
        _stepImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _stepImageView.image = [UIImage imageNamed:@"create_servicer_step3"];
    }
    return _stepImageView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.text = @"Tell us a bit more about your business or service";
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.textColor = UIColorFromRGB(0x1B3257);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

- (SAMCTextView *)descriptionTextView
{
    if (_descriptionTextView == nil) {
        _descriptionTextView = [[SAMCTextView alloc] init];
        _descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _descriptionTextView.placeholder = @"i.e. your specialization, years of experience, how do you work with your client, etc.";
        _descriptionTextView.delegate = self;
    }
    return _descriptionTextView;
}

- (UIButton *)skipButton
{
    if (_skipButton == nil) {
        _skipButton = [[UIButton alloc] init];
        _skipButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        [_skipButton addConstraint:[NSLayoutConstraint constraintWithItem:_skipButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:30.0f]];
        _skipButton.layer.cornerRadius = 15.0f;
        _skipButton.backgroundColor = UIColorFromRGB(0xA2AEBC);
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _skipButton;
}

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addConstraint:[NSLayoutConstraint constraintWithItem:_doneButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:30.0f]];
        _doneButton.layer.cornerRadius = 15.0f;
        _doneButton.backgroundColor = UIColorFromRGB(0x88B1D2);
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

@end
