//
//  SAMCSettingViewController.m
//  SamChat
//
//  Created by HJ on 7/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableViewCell.h"
#import "UIAlertView+NTESBlock.h"
#import "SAMCAccountManager.h"
#import "SAMCCSAStepOneViewController.h"
#import "SAMCSettingPortraitCell.h"
#import <AWSS3/AWSS3.h>
#import "UIImage+NTES.h"
#import "NTESFileLocationHelper.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "SAMCResourceManager.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCContactManager.h"
#import "SDWebImageManager.h"


@interface SAMCSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *data;

@end

@implementation SAMCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        [self prepareCustomModeData];
    } else {
        [self prepareSPModeData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchToUserMode:(NSNotification *)notification
{
    SAMCUserModeType mode = [[[notification userInfo] objectForKey:SAMCSwitchToUserModeKey] integerValue];
    if (mode == SAMCUserModeTypeCustom) {
        [self prepareCustomModeData];
    } else {
        [self prepareSPModeData];
    }
    [self.tableView reloadData];
}

- (void)setupSubviews
{
    self.navigationItem.title = @"Settings";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)prepareCustomModeData
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    
    NSDictionary *portraitCellExtra = @{SAMC_CELL_EXTRA_UID_KEY:uid.length ? uid : [NSNull null],
                                        SAMC_CELL_EXTRA_TOP_TEXT_KEY:@"My Profile",
                                        SAMC_CELL_EXTRA_BOTTOM_TEXT_KEY:@"My QR Code",
                                        SAMC_CELL_EXTRA_TOP_ACTION_KEY:@"onTouchPortraitTop:",
                                        SAMC_CELL_EXTRA_BOTTOM_ACTION_KEY:@"onTouchPortraitBottom:"};
    NSArray *data = @[
                      @{
                          HeaderTitle:@"Account",
                          RowContent :@[
                                  @{
                                      ExtraInfo     : portraitCellExtra,
                                      CellClass     : @"SAMCSettingPortraitCell",
                                      RowHeight     : @(100),
                                      CellAction    : @"onTouchPortraitAvatar:",
                                      ShowAccessory : @(NO),
                                      ForbidSelect  : @(YES)
                                      },
                                  @{
                                      Title         : @"Create Service Account",
                                      CellClass     : @"NTESColorButtonCell",
                                      RowHeight     : @(60),
                                      CellAction    : @"createSamPros:",
                                      ExtraInfo     : @(1),
                                      ForbidSelect  : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"Preferences",
                          RowContent :@[
                                  @{
                                      Title        : @"Notifications",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  @{
                                      Title        : @"Options",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"About",
                          RowContent :@[
                                  @{
                                      Title        : @"About SamChat",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  @{
                                      Title        : @"F.A.Q.",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)prepareSPModeData
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSDictionary *portraitCellExtra = @{SAMC_CELL_EXTRA_UID_KEY:uid.length ? uid : [NSNull null],
                                        SAMC_CELL_EXTRA_TOP_TEXT_KEY:@"Service Profile",
                                        SAMC_CELL_EXTRA_BOTTOM_TEXT_KEY:@"Service QR Code",
                                        SAMC_CELL_EXTRA_TOP_ACTION_KEY:@"onTouchPortraitTop:",
                                        SAMC_CELL_EXTRA_BOTTOM_ACTION_KEY:@"onTouchPortraitBottom:"};
    NSArray *data = @[
                      @{
                          HeaderTitle:@"Service Account",
                          RowContent :@[
                                  @{
                                      ExtraInfo     : portraitCellExtra,
                                      CellClass     : @"SAMCSettingPortraitCell",
                                      RowHeight     : @(100),
                                      CellAction    : @"onTouchPortraitAvatar:",
                                      ShowAccessory : @(NO),
                                      ForbidSelect : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      @{
                          HeaderTitle:@"Service Preferences",
                          RowContent :@[
                                  @{
                                      Title        : @"Notifications",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  @{
                                      Title        : @"Subscription and plans",
                                      CellClass    : @"NTESColorButtonCell",
                                      RowHeight    : @(60),
                                      CellAction   : @"logoutCurrentAccount:",
                                      ExtraInfo    : @(1),
                                      ForbidSelect : @(YES)
                                      },
                                  ],
                          FooterTitle:@""
                          },
                      ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NIMCommonTableSection *tableSection = self.data[section];
    return [tableSection.rows count];
}

#define SepViewTag 10001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DefaultTableCell = @"UITableViewCell";
    NIMCommonTableSection *tableSection = self.data[indexPath.section];
    NIMCommonTableRow     *tableRow     = tableSection.rows[indexPath.row];
    NSString *identity = tableRow.cellClassName.length ? tableRow.cellClassName : DefaultTableCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        Class clazz = NSClassFromString(identity);
        cell = [[clazz alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identity];
        UIView *sep = [[UIView alloc] initWithFrame:CGRectZero];
        sep.tag = SepViewTag;
        sep.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        sep.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:sep];
    }
    if (![cell respondsToSelector:@selector(refreshData:tableView:)]) {
        UITableViewCell *defaultCell = (UITableViewCell *)cell;
        [self refreshData:tableRow cell:defaultCell];
    }else{
        [(id<NIMCommonTableViewCell>)cell refreshData:tableRow tableView:tableView];
    }
    cell.accessoryType = tableRow.showAccessory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-20*2, 44)];
    customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:customView.frame];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.opaque = NO;
    headerLabel.highlightedTextColor = [UIColor darkGrayColor];
    
    NIMCommonTableSection *tableSection = self.data[section];
    headerLabel.text = tableSection.headerTitle;
    [customView addSubview:headerLabel];
    
    return customView;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NIMCommonTableSection *tableSection = self.data[section];
//    return tableSection.headerTitle;
//}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMCommonTableSection *tableSection = self.data[indexPath.section];
    NIMCommonTableRow     *tableRow     = tableSection.rows[indexPath.row];
    return tableRow.uiRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Private
- (void)refreshData:(NIMCommonTableRow *)rowData cell:(UITableViewCell *)cell{
    cell.textLabel.text = rowData.title;
    cell.detailTextLabel.text = rowData.detailTitle;
}

#pragma mark - Action
- (void)logoutCurrentAccount:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"退出当前帐号？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
                [[SAMCAccountManager sharedManager] logout:^(NSError * _Nullable error) {
                     extern NSString *NTESNotificationLogout;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
                }];
                break;
            default:
                break;
        }
    }];
}

- (void)createSamPros:(id)sender
{
    SAMCCSAStepOneViewController *vc = [[SAMCCSAStepOneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchPortraitTop:(id)sender
{
    DDLogDebug(@"onTouchPortraitTop");
}

- (void)onTouchPortraitBottom:(id)sender
{
    DDLogDebug(@"onTouchPortraitBottom");
}

- (void)onTouchPortraitAvatar:(id)sender
{
    DDLogDebug(@"onTouchPortraitAvatar");
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
                [[SAMCContactManager sharedManager] updateAvatar:urlString completion:^(SAMCUser * _Nullable user, NSError * _Nullable error) {
                    if (!error) {
                        [[SDWebImageManager sharedManager] saveImageToCache:imageForAvatarUpload forURL:[NSURL URLWithString:user.userInfo.avatar]];
                        [wself.tableView reloadData];
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
