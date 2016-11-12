//
//  SAMCMyProfileViewController.m
//  SamChat
//
//  Created by HJ on 10/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMyProfileViewController.h"
#import "SAMCCardPortraitView.h"
#import "SAMCSessionViewController.h"
#import "SAMCPublicManager.h"
#import "SAMCAccountManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "SAMCTableCellFactory.h"
#import "SAMCResourceManager.h"
#import "UIImage+NTES.h"
#import "NTESFileLocationHelper.h"
#import "SAMCUserManager.h"
#import "SAMCSettingManager.h"
#import "SDWebImageManager.h"
#import "SAMCEditProfileViewController.h"
#import "SAMCSelectLocationViewController.h"
#import "SAMCEditCellPhoneViewController.h"

@interface SAMCMyProfileViewController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate, SAMCUserManagerDelegate>

@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SAMCMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"My Profile";
    
    self.user = [SAMCAccountManager sharedManager].currentUser;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:self.tableView];
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    
    SAMCCardPortraitView *headerView = [[SAMCCardPortraitView alloc] initWithFrame:CGRectMake(0, 0, 0, 140)];
    headerView.avatarUrl = _user.userInfo.avatar;
    [headerView.avatarView addTarget:self action:@selector(onTouchPortraitAvatar:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[SAMCUserManager sharedManager] addDelegate:self];
}

- (void)dealloc
{
    [[SAMCUserManager sharedManager] removeDelegate:self];
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 1:
                {
                    SAMCEditCellPhoneViewController *vc = [[SAMCEditCellPhoneViewController alloc] initWithCountryCode:self.user.userInfo.countryCode];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2:
                {
                    NSDictionary *emailDict = @{SAMC_EMAIL:self.user.userInfo.email?:@""};
                    SAMCEditProfileViewController *vc = [[SAMCEditProfileViewController alloc] initWithProfileType:SAMCEditProfileTypeEmail
                                                                                                       profileDict:emailDict];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:
                {
                    [self updateLocation];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 4;
            break;
        default:
            break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Name";
                    NSString *name = self.user.userInfo.username;
                    cell.detailTextLabel.text = [name length] ? name :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_username"];
                }
                    break;
                case 1:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Phone no.";
                    NSString *countryCode = self.user.userInfo.countryCode;
                    countryCode = [countryCode length] ? [NSString stringWithFormat:@"+%@ ",countryCode] : @"";
                    NSString *phone = self.user.userInfo.cellPhone;
                    phone = [phone length] ? phone : @" ";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", countryCode, phone];
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_phone"];
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Email";
                    NSString *email = self.user.userInfo.email;
                    email = [email length] ? email : @" ";
                    cell.detailTextLabel.text = email;
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_email"];
                }
                    break;
                case 3:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.textLabel.text = @"Location";
                    NSString *address = self.user.userInfo.address;
                    cell.detailTextLabel.text = [address length] ? address :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_location"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - Action
- (void)onTouchPortraitAvatar:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // When showing the ImagePicker update the status bar and nav bar properties.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    navigationController.topViewController.title = @"Photos";
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.barTintColor = SAMC_COLOR_NAV_LIGHT;
    navigationController.navigationBar.topItem.rightBarButtonItem.tintColor = SAMC_COLOR_INK;
    [navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - SAMCUserManagerDelegate
- (void)onUserInfoChanged:(SAMCUser *)user
{
    if ([user.userId isEqualToString:self.user.userId]) {
        self.user = user;
//        SAMCCardPortraitView *headerView = (SAMCCardPortraitView *)self.tableView.tableHeaderView;
//        headerView.avatarUrl = user.userInfo.avatar;
        [self.tableView reloadData];
    }
}

#pragma mark - Private
- (void)uploadImage:(UIImage *)image
{
    UIImage *imageForAvatarUpload = [image imageForAvatarUpload];
    //    NSString *fileName = [NTESFileLocationHelper genFilenameWithExt:@"jpg"];
    NSString *currentAccount = [SAMCAccountManager sharedManager].currentAccount;
    NSInteger timeInterval = [@([[NSDate date] timeIntervalSince1970] * 1000) integerValue];
    NSString *fileName = [NSString stringWithFormat:@"org_%@_%ld.jpg",currentAccount,timeInterval];
    
    NSString *filePath = [[NTESFileLocationHelper getAppDocumentPath] stringByAppendingPathComponent:fileName];
    NSData *data = UIImageJPEGRepresentation(imageForAvatarUpload, 1.0);
    BOOL success = data && [data writeToFile:filePath atomically:YES];
    __weak typeof(self) wself = self;
    if (success) {
        [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeBlack];
        NSString *key = [NSString stringWithFormat:@"%@%@", SAMC_AWSS3_AVATAR_ORG_PATH, fileName];
        [[SAMCResourceManager sharedManager] upload:filePath key:key contentType:@"image/jpeg" progress:nil completion:^(NSString *urlString, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error && wself) {
                DDLogDebug(@"url: %@", urlString);
                [[SAMCSettingManager sharedManager] updateAvatar:urlString completion:^(SAMCUser * _Nullable user, NSError * _Nullable error) {
                    if (!error) {
                        [[SDWebImageManager sharedManager] saveImageToCache:imageForAvatarUpload forURL:[NSURL URLWithString:user.userInfo.avatar]];
                        SAMCCardPortraitView *headerView = (SAMCCardPortraitView *)wself.tableView.tableHeaderView;
                        headerView.avatarUrl = user.userInfo.avatar;
                    } else {
                        [wself.view makeToast:@"设置头像失败，请重试" duration:2 position:CSToastPositionCenter];
                    }
                }];
            } else {
                [wself.view makeToast:@"图片上传失败，请重试" duration:2 position:CSToastPositionCenter];
            }
        }];
    }else{
        [self.view makeToast:@"图片保存失败，请重试" duration:2 position:CSToastPositionCenter];
    }
}

- (void)updateLocation
{
    SAMCSelectLocationViewController *vc = [[SAMCSelectLocationViewController alloc] initWithHideCurrentLocation:YES userMode:SAMCUserModeTypeCustom];
    __weak typeof(self) wself = self;
    vc.selectBlock = ^(NSDictionary *location, BOOL isCurrentLocation){
        NSDictionary *locationDict;
        if (isCurrentLocation) {
            return;
        }
        locationDict = location;
        
        NSDictionary *profileDict = @{SAMC_LOCATION:locationDict};
        [SVProgressHUD showWithStatus:@"updating" maskType:SVProgressHUDMaskTypeBlack];
        [[SAMCSettingManager sharedManager] updateProfile:profileDict completion:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (error) {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2 position:CSToastPositionCenter];
            } else {
                [wself.view makeToast:@"success" duration:2 position:CSToastPositionCenter];
            }
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
