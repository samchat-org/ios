//
//  SAMCSessionCardViewController.h
//  SamChat
//
//  Created by HJ on 8/10/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAMCSession;

@interface SAMCSessionCardViewController : UIViewController

@property (nonatomic,strong) UITableView *tableView;

- (instancetype)initWithSession:(SAMCSession *)session;

@end
