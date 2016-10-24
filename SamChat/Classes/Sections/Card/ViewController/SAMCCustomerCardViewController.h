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

- (instancetype)initWithUser:(SAMCUser *)user isMyCustomer:(BOOL)isMyCustomer;

@end
