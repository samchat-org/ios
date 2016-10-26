//
//  SAMCContactSelectViewController.h
//  SamChat
//
//  Created by HJ on 10/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMContactSelectConfig.h"

typedef void(^ContactSelectFinishBlock)(NSArray *);
typedef void(^ContactSelectCancelBlock)(void);

@protocol SAMCContactSelectDelegate <NSObject>

@optional

- (void)didFinishedSelect:(NSArray *)selectedContacts; // 返回userID

- (void)didCancelledSelect;

@end


@interface SAMCContactSelectViewController : UIViewController

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, strong, readonly) id<NIMContactSelectConfig> config;

@property (nonatomic, weak) id<SAMCContactSelectDelegate> delegate;

@property (nonatomic, copy) ContactSelectFinishBlock finshBlock;

@property (nonatomic, copy) ContactSelectCancelBlock cancelBlock;

- (instancetype)initWithConfig:(id<NIMContactSelectConfig>) config;
- (void)show;

@end
