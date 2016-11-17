//
//  SAMCAddContactViewController.m
//  SamChat
//
//  Created by HJ on 8/22/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCAddContactViewController.h"
#import "SAMCQRCodeScanViewController.h"
#import "SAMCUserManager.h"
#import "UIView+Toast.h"
#import <AddressBook/AddressBook.h>
#import "SAMCGroupedPeoples.h"
#import "SAMCPeopleDataMember.h"
#import "SAMCPeopleDataCell.h"
#import "UIAlertView+NTESBlock.h"
#import "SAMCUserManager.h"
#import "SAMCPhone.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "SAMCServerErrorHelper.h"
#import "SAMCServicerCardViewController.h"
#import "SAMCCustomerCardViewController.h"
#import "SAMCPublicManager.h"

@interface SAMCAddContactViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SAMCGroupedPeoples *peoples;

@end

@implementation SAMCAddContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareData];
    [self setupSubviews];
    [self setUpNavItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    if (self.currentUserMode == SAMCUserModeTypeSP) {
        self.navigationItem.title = @"Add Customer";
    } else {
        self.navigationItem.title = @"Add Service Provider";
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    //searchBar.delegate = self;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tableView.tableHeaderView = searchBar;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)setUpNavItem
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn addTarget:self action:@selector(onOpera:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"QR Code" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [rightBtn sizeToFit];
    if (self.currentUserMode == SAMCUserModeTypeSP) {
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightBtn setTitleColor:UIColorFromRGBA(0xFFFFFF, 0.5) forState:UIControlStateHighlighted];
    } else {
        [rightBtn setTitleColor:SAMC_COLOR_INGRABLUE forState:UIControlStateNormal];
        [rightBtn setTitleColor:UIColorFromRGBA(SAMC_COLOR_RGB_INGRABLUE, 0.5) forState:UIControlStateHighlighted];
    }
    UIBarButtonItem *navRightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, navRightItem];
}

- (void)prepareData
{
    __block NSArray *peoplesInfo;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            CFErrorRef *aError = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, aError);
            peoplesInfo = [self readAddressBook:addressBook];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        peoplesInfo = [self readAddressBook:addressBook];
    }
    else {
        // failed to read, no auth
    }
    _peoples = [[SAMCGroupedPeoples alloc] initWithPeoples:peoplesInfo];
}

- (NSArray<SAMCPeopleInfo *> *)readAddressBook:(ABAddressBookRef)addressBook
{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef peoplesRef = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableArray *peoplesInfo = [[NSMutableArray alloc] init];
    
    for ( int i = 0; i < numberOfPeople; i++){
        SAMCPeopleInfo *peopleInfo = [[SAMCPeopleInfo alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(peoplesRef, i);
        
        peopleInfo.firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        peopleInfo.lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        peopleInfo.middleName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phone) > 0) {
            // get the first one only
            peopleInfo.phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
        }
        [peoplesInfo addObject:peopleInfo];
    }
    return peoplesInfo;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SAMCPeopleDataMember *peopleMember = [_peoples memberOfIndex:indexPath];
    SAMCPeopleInfo *peopleInfo = peopleMember.info;
    DDLogDebug(@"select people: %@, phone: %@", [peopleMember memberId], peopleInfo.phone);
    __weak typeof(self) wself = self;
    [[SAMCUserManager sharedManager] queryAccurateUser:peopleInfo.phone type:SAMCQueryAccurateUserTypeCellPhone completion:^(NSDictionary * _Nullable userDict, NSError * _Nullable error) {
        if (error) {
            if (error.code == SAMCServerErrorUserNotExists) {
                [wself alertToInvite:peopleInfo];
            } else {
                [wself.view makeToast:error.userInfo[NSLocalizedDescriptionKey] duration:2.0f position:CSToastPositionCenter];
            }
        } else {
            SAMCUser *user = [SAMCUser userFromDict:userDict];
            if ((self.currentUserMode == SAMCUserModeTypeCustom) && ([user.userInfo.usertype isEqual:@(SAMCUserTypeCustom)])) {
                [wself alertToInvite:peopleInfo];
            } else {
                [wself enterPersonalCard:[SAMCUser userFromDict:userDict]];
            }
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peoples memberCountOfGroup:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_peoples groupCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"SAMCPeopleDataCellId";
    SAMCPeopleDataCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCPeopleDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SAMCPeopleDataMember *peopleMember = [_peoples memberOfIndex:indexPath];
    SAMCPeopleInfo *peopleInfo = peopleMember.info;
    cell.firstNameLabel.text = peopleInfo.firstName;
    cell.lastNameLabel.text = peopleInfo.lastName;
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_peoples titleOfGroup:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _peoples.sortedGroupTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - Action
- (void)onOpera:(id)sender
{
    SAMCQRCodeScanViewController *vc = [[SAMCQRCodeScanViewController alloc] initWithUserMode:self.currentUserMode segmentIndex:0];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)alertToInvite:(SAMCPeopleInfo *)peopleInfo
{
    NSString *inviteMsg = @"This contact is not on Samchat yet. Would you like to invite them to Samchat?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invite Contact" message:inviteMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
    __weak typeof(self) wself = self;
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
                [wself sendInviteMessage:peopleInfo];
                break;
            default:
                break;
        }
    }];
}

- (void)sendInviteMessage:(SAMCPeopleInfo *)peopleInfo
{
    SAMCPhone *phone = [SAMCPhone phoneWithCountryCode:nil cellphone:peopleInfo.phone];
    [SVProgressHUD showWithStatus:@"sending invite message..." maskType:SVProgressHUDMaskTypeBlack];
    __weak typeof(self) wself = self;
    [[SAMCUserManager sharedManager] sendInviteMsg:@[phone] completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        NSString *toast;
        if (error) {
            toast = error.userInfo[NSLocalizedDescriptionKey];
        } else {
            toast = @"Invite success";
        }
        [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
    }];
}

- (void)enterPersonalCard:(SAMCUser *)user
{
    UIViewController *vc;
    if (self.currentUserMode == SAMCUserModeTypeCustom) {
        vc = [[SAMCServicerCardViewController alloc] initWithUserId:user.userId];
    } else {
        BOOL isMyCustomer = [[SAMCUserManager sharedManager] isMyCustomer:user.userId];
        vc = [[SAMCCustomerCardViewController alloc] initWithUser:user isMyCustomer:isMyCustomer];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)onTouchSearch:(id)sender
//{
//    NSString *key = self.searchTextField.text;
//    __weak typeof(self) wself = self;
//    [[SAMCUserManager sharedManager] queryFuzzyUserWithKey:key completion:^(NSArray * _Nullable users, NSError * _Nullable error) {
//        if (error) {
//            NSString *toast = error.userInfo[NSLocalizedDescriptionKey];
//            [wself.view makeToast:toast duration:2.0f position:CSToastPositionCenter];
//            return;
//        }
//        DDLogDebug(@"query fuzzy users: %@", users);
//    }];
//}

@end
