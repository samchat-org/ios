//
//  SAMCTableViewDelegate.h
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCTableViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UIViewController *viewController;

- (instancetype) initWithTableData:(NSArray *(^)(void))data viewController:(UIViewController *)controller;
- (NSArray *)data;

@end
