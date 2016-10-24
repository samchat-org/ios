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
#import "SAMCServerAPIMacro.h"
#import "SAMCUserManager.h"
#import "SDWebImageManager.h"

@interface SAMCMyProfileViewController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

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
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
            rows = 3;
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
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
                    cell.textLabel.text = @"Phone no.";
                    NSString *phone = self.user.userInfo.cellPhone;
                    cell.detailTextLabel.text = [phone length] ? phone :@" ";
                    cell.imageView.image = [UIImage imageNamed:@"ico_option_phone"];
                }
                    break;
                case 2:
                {
                    cell = [SAMCTableCellFactory commonDetailCell:tableView accessoryType:UITableViewCellAccessoryNone];
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
                [[SAMCUserManager sharedManager] updateAvatar:urlString completion:^(SAMCUser * _Nullable user, NSError * _Nullable error) {
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

@end
