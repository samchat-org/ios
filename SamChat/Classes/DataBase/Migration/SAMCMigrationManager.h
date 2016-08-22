//
//  SAMCMigrationManager.h
//  SamChat
//
//  Created by HJ on 8/22/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDatabase.h>
#import <fmdb/FMDatabaseQueue.h>

@protocol SAMCMigrating;

@interface SAMCMigrationManager : NSObject

+ (instancetype)managerWithDatabaseQueue:(FMDatabaseQueue *)queue;

@property (nonatomic, readonly) uint64_t currentVersion;
@property (nonatomic, readonly) uint64_t originVersion;
@property (nonatomic, readonly) NSArray *migrations;
@property (nonatomic, readonly) NSArray *appliedVersions;
@property (nonatomic, readonly) NSArray *pendingVersions;

- (id<SAMCMigrating>)migrationForVersion:(uint64_t)version;

- (void)addMigration:(id<SAMCMigrating>)migration;
- (void)addMigrations:(NSArray *)migrations;

@property (nonatomic, readonly) BOOL hasMigrationsTable;

- (BOOL)createMigrationsTable:(NSError **)error;

@property (nonatomic, readonly) BOOL needsMigration;

- (BOOL)migrateDatabaseToVersion:(uint64_t)version progress:(void (^)(NSProgress *progress))progressBlock error:(NSError **)error;

@end

@protocol SAMCMigrating <NSObject>

@property (nonatomic, readonly) uint64_t version;

- (BOOL)migrateDatabase:(FMDatabase *)db error:(out NSError *__autoreleasing *)error;

@end

extern NSString *const SAMCMigrationManagerErrorDomain;
extern NSString *const SAMCMigrationManagerProgressVersionUserInfoKey;
extern NSString *const SAMCMigrationManagerProgressMigrationUserInfoKey;
typedef NS_ENUM(NSUInteger, SAMCMigrationManagerError) {
    /// Indicates that migration was halted due to cancellation
    SAMCMigrationManagerErrorMigrationCancelled  = 1
};
