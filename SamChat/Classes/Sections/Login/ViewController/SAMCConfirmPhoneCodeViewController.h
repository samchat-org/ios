//
//  SAMCConfirmPhoneCodeViewController.h
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCConfirmPhoneCodeViewController : UIViewController

@property (nonatomic, getter=isSignupOperation) BOOL signupOperation;

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *phoneNumber;

@end
