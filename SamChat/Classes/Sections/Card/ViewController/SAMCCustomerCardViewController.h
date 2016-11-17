//
//  SAMCCustomerCardViewController.h
//  SamChat
//
//  Created by HJ on 10/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCUser.h"

@interface SAMCCustomerCardViewController : UIViewController

@property (nonatomic, assign) BOOL showInfoOnly;

- (instancetype)initWithUserId:(NSString *)userId;

@end
