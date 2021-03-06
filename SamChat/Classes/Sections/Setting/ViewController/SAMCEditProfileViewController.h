//
//  SAMCEditProfileViewController.h
//  SamChat
//
//  Created by HJ on 11/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SAMCEditProfileType) {
    SAMCEditProfileTypeEmail,
    SAMCEditProfileTypeSPCompanyName,
    SAMCEditProfileTypeSPServiceCategory,
    SAMCEditProfileTypeSPPhone,
    SAMCEditProfileTypeSPEmail,
    SAMCEditProfileTypeSPDescription
};

@interface SAMCEditProfileViewController : UIViewController

- (instancetype)initWithProfileType:(SAMCEditProfileType)profileType profileDict:(NSDictionary *)profileDict;

@end
