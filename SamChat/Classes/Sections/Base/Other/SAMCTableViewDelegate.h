//
//  SAMCTableViewDelegate.h
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAMCTableReloadDelegate <NSObject>

- (void)sortAndReload;

@end

@interface SAMCTableViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UIViewController<SAMCTableReloadDelegate> *viewController;

- (instancetype) initWithTableData:(NSMutableArray *(^)(void))data viewController:(UIViewController<SAMCTableReloadDelegate> *)controller;
- (NSMutableArray *)data;

@end
