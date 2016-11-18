//
//  SAMCEditTeamNameViewController.m
//  SamChat
//
//  Created by HJ on 11/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCEditTeamNameViewController.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "NSString+SAMC.h"

@interface SAMCEditTeamNameViewController ()

@property (nonatomic, strong) NIMTeam *team;

@property (nonatomic, strong) UIBarButtonItem *rightNavItem;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *normalTextField;

@end

@implementation SAMCEditTeamNameViewController

- (instancetype)initWithTeam:(NIMTeam *)team
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _team = team;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_normalTextField becomeFirstResponder];
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.navigationItem.title = @"Group Name";
    [self setupNavItem];
    [self.view addSubview:self.normalTextField];
    [self.view addSubview:self.tipLabel];
    _normalTextField.text = self.team.teamName;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_normalTextField]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_normalTextField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_tipLabel]-5-[_normalTextField(40)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_normalTextField, _tipLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_tipLabel]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tipLabel)]];
}

- (void)setupNavItem
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    UIButton *rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavButton addTarget:self action:@selector(updateTeamName) forControlEvents:UIControlEventTouchUpInside];
    [rightNavButton setTitle:@"Save" forState:UIControlStateNormal];
    [rightNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightNavButton setTitleColor:UIColorFromRGBA(0xFFFFFF, 0.5) forState:UIControlStateHighlighted];
    [rightNavButton setTitleColor:UIColorFromRGBA(0xFFFFFF, 0.5) forState:UIControlStateDisabled];
    [rightNavButton sizeToFit];
    
    _rightNavItem = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    _rightNavItem.enabled = false;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, _rightNavItem];
}

#pragma mark - Action
- (void)updateTeamName
{
    NSString *name = _normalTextField.text;
    if (name.length) {
        [[NIMSDK sharedSDK].teamManager updateTeamName:name teamId:self.team.teamId completion:^(NSError *error) {
            if (!error) {
                self.team = [[[NIMSDK sharedSDK] teamManager] teamById:self.team.teamId];
//                [self.view makeToast:@"change success" duration:2.0 position:CSToastPositionCenter];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.view makeToast:@"change failed" duration:2.0 position:CSToastPositionCenter];
            }
        }];
    }
}

#pragma mark -
- (void)normalTextFieldEditingChanged:(UITextField *)textField
{
    self.rightNavItem.enabled = [textField.text samc_isValidTeamname];
}

- (void)normalTextFieldEditingDidEndOnExit:(id)sender
{
    [self updateTeamName];
}

#pragma mark - lazy load
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
        _tipLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5f);
        _tipLabel.text = @"Group Name";
    }
    return _tipLabel;
}

- (UITextField *)normalTextField
{
    if (_normalTextField == nil) {
        _normalTextField = [[UITextField alloc] init];
        _normalTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _normalTextField.backgroundColor = [UIColor whiteColor];
        _normalTextField.borderStyle = UITextBorderStyleNone;
        _normalTextField.font = [UIFont systemFontOfSize:17.0f];
        _normalTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _normalTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _normalTextField.textColor = SAMC_COLOR_INK;
        _normalTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        _normalTextField.leftViewMode = UITextFieldViewModeAlways;
        _normalTextField.returnKeyType = UIReturnKeyDone;
        [_normalTextField addTarget:self action:@selector(normalTextFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [_normalTextField addTarget:self action:@selector(normalTextFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _normalTextField;
}

@end
