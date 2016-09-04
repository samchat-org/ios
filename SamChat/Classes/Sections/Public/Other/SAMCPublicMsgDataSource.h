//
//  SAMCPublicMsgDataSource.h
//  SamChat
//
//  Created by HJ on 9/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMKitMessageProvider.h"
#import "SAMCPublicSession.h"

@protocol SAMCPublicMsgDatasourceDelegate <NSObject>

- (void)messageDataIsReady;

@end

@interface SAMCPublicMsgDataSource : NSObject

- (instancetype)initWithSession:(SAMCPublicSession *)session
               showTimeInterval:(NSTimeInterval)timeInterval
                          limit:(NSInteger)limit;

@property (nonatomic, strong) NSMutableArray      *modelArray;
@property (nonatomic, readonly) NSInteger         messageLimit;                //每页消息显示条数
@property (nonatomic, readonly) NSInteger         showTimeInterval;            //两条消息相隔多久显示一条时间戳
@property (nonatomic, weak) id<SAMCPublicMsgDatasourceDelegate> delegate;

- (NSInteger)indexAtModelArray:(NIMMessageModel*)model;

//复位消息
- (void)resetMessages:(void(^)(NSError *error)) handler;

//数据对外接口
- (void)loadHistoryMessagesWithComplete:(void(^)(NSInteger index , NSArray *messages ,NSError *error))handler;

- (NSArray<NSNumber *> *)addMessageModels:(NSArray*)models;

- (NSArray<NSNumber *> *)deleteMessageModel:(NIMMessageModel*)model;

//清理缓存数据
- (void)cleanCache;
@end
