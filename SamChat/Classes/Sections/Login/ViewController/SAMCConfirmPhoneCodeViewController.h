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

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *phoneNumber;

@end
