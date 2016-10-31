//
//  SAMCDBBase.m
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDBBase.h"
#import "NTESFileLocationHelper.h"

@implementation SAMCDBBase

- (instancetype)initWithName:(NSString *)name
{
    NSAssert((name!=nil) && (name.length>0), @"data base name should not be empty.");
    self = [super init];
    if (self)
    {
        [self openDataBase:name];
    }
    return self;
}

- (void)dealloc
{
    [_queue close];
}

- (void)openDataBase:(NSString *)name
{
    NSString *filepath = [[NTESFileLocationHelper userDirectory] stringByAppendingString:name];
    DDLogDebug(@"filepath %@", filepath);
    _queue = [FMDatabaseQueue databaseQueueWithPath:filepath];
}

- (BOOL)needsMigration
{
    return [_migrationManager needsMigration];
}

- (BOOL)doMigration
{
    DDLogDebug(@"Has `schema_migrations` table?: %@", _migrationManager.hasMigrationsTable ? @"YES" : @"NO");
    DDLogDebug(@"Origin Version: %llu", _migrationManager.originVersion);
    DDLogDebug(@"Current version: %llu", _migrationManager.currentVersion);
    DDLogDebug(@"All migrations: %@", _migrationManager.migrations);
    DDLogDebug(@"Applied versions: %@", _migrationManager.appliedVersions);
    DDLogDebug(@"Pending versions: %@", _migrationManager.pendingVersions);
    BOOL result = [_migrationManager migrateDatabaseToVersion:INT64_MAX progress:nil error:NULL];
    _migrationManager = nil; // no need after migration
    return result;
}

@end
