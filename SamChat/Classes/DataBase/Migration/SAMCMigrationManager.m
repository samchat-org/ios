//
//  SAMCMigrationManager.m
//  SamChat
//
//  Created by HJ on 8/22/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMigrationManager.h"

NSString *const SAMCMigrationManagerErrorDomain = @"com.github.gknows.SAMCMigrationManager.errors";
NSString *const SAMCMigrationManagerProgressVersionUserInfoKey = @"version";
NSString *const SAMCMigrationManagerProgressMigrationUserInfoKey = @"migration";

@interface SAMCMigrationManager ()
@property (nonatomic, weak) FMDatabaseQueue *queue;
@property (nonatomic, strong) NSArray *migrations;
@property (nonatomic, strong) NSMutableArray *externalMigrations;
@end

@implementation SAMCMigrationManager

+ (instancetype)managerWithDatabaseQueue:(FMDatabaseQueue *)queue
{
    return [[self alloc] initWithDatabaseQueue:queue];
}

// Designated initializer
- (id)initWithDatabaseQueue:(FMDatabaseQueue *)queue
{
    if (!queue) [NSException raise:NSInvalidArgumentException format:@"Cannot initialize a `%@` with nil `database`.", [self class]];
    self = [super init];
    if (self) {
        _queue = queue;
        _externalMigrations = [NSMutableArray new];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (void)dealloc
{
}

- (BOOL)hasMigrationsTable
{
    __block BOOL result = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name=?", @"schema_migrations"];
        if ([resultSet next]) {
            [resultSet close];
            result = YES;
        }
    }];
    return result;
}

- (BOOL)needsMigration
{
    return !self.hasMigrationsTable || [self.pendingVersions count] > 0;
}

- (BOOL)createMigrationsTable:(NSError **)error
{
    __block BOOL success;
    [self.queue inDatabase:^(FMDatabase *db) {
        success = [db executeStatements:@"CREATE TABLE schema_migrations(version INTEGER UNIQUE NOT NULL)"];
        if (!success && error) {
            *error = db.lastError;
        }
    }];
    return success;
}

- (uint64_t)currentVersion
{
    if (!self.hasMigrationsTable) return 0;
    
    __block uint64_t version = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT MAX(version) FROM schema_migrations"];
        if ([resultSet next]) {
            version = [resultSet unsignedLongLongIntForColumnIndex:0];
        }
        [resultSet close];
    }];
    return version;;
}

- (uint64_t)originVersion
{
    if (!self.hasMigrationsTable) return 0;
    
    __block uint64_t version = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT MIN(version) FROM schema_migrations"];
        if ([resultSet next]) {
            version = [resultSet unsignedLongLongIntForColumnIndex:0];
        }
        [resultSet close];
    }];
    return version;
}

- (NSArray *)appliedVersions
{
    if (!self.hasMigrationsTable) return nil;
    
    __block NSMutableArray *versions = [NSMutableArray new];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT version FROM schema_migrations"];
        while ([resultSet next]) {
            uint64_t version = [resultSet unsignedLongLongIntForColumnIndex:0];
            [versions addObject:@(version)];
        }
        [resultSet close];
    }];
    return [versions sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)pendingVersions
{
    if (!self.hasMigrationsTable) {
        return [[self.migrations valueForKey:@"version"] sortedArrayUsingSelector:@selector(compare:)];
    }
    
    NSMutableArray *pendingVersions = [[[self migrations] valueForKey:@"version"] mutableCopy];
    [pendingVersions removeObjectsInArray:self.appliedVersions];
    return [pendingVersions sortedArrayUsingSelector:@selector(compare:)];
}

- (void)addMigration:(id<SAMCMigrating>)migration
{
    NSParameterAssert(migration);
    [self addMigrationsAndSortByVersion:@[ migration ]];
}

- (void)addMigrations:(NSArray *)migrations
{
    NSParameterAssert(migrations);
    if (![migrations isKindOfClass:[NSArray class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Failed to add migrations because `migrations` argument is not an array." userInfo:nil];
    }
    for (id<NSObject> migration in migrations) {
        if (![migration conformsToProtocol:@protocol(SAMCMigrating)]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Failed to add migrations because an object in `migrations` array doesn't conform to the `SAMCMigrating` protocol." userInfo:nil];
        }
    }
    [self addMigrationsAndSortByVersion:migrations];
}

- (NSArray *)migrations
{
    // Memoize the migrations list
    if (_migrations) return _migrations;
    
    NSMutableArray *migrations = [NSMutableArray new];
    
    // Append any externally added migrations
    [migrations addObjectsFromArray:self.externalMigrations];
    
    // Sort into our final set
    _migrations = [migrations sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"version" ascending:YES] ]];
    return _migrations;
}

- (id<SAMCMigrating>)migrationForVersion:(uint64_t)version
{
    for (id<SAMCMigrating>migration in [self migrations]) {
        if (migration.version == version) return migration;
    }
    return nil;
}

- (BOOL)migrateDatabaseToVersion:(uint64_t)version progress:(void (^)(NSProgress *progress))progressBlock error:(NSError **)error
{
    NSArray *pendingVersions = self.pendingVersions;
    __block NSProgress *progress = [NSProgress progressWithTotalUnitCount:[pendingVersions count]];
    
    __block BOOL success = YES;
    __block BOOL breakFlag = NO;
    for (NSNumber *migrationVersionNumber in pendingVersions) {
        [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            uint64_t migrationVersion = [migrationVersionNumber unsignedLongLongValue];
            if (migrationVersion > version) {
                breakFlag = YES;
                return;
            }
            
            id<SAMCMigrating> migration = [self migrationForVersion:migrationVersion];
            success = [migration migrateDatabase:db error:error];
            if (!success) {
                *rollback = YES;
                breakFlag = YES;
                return;
            }
            
            success = [db executeUpdate:@"INSERT INTO schema_migrations(version) VALUES (?)", @(migration.version)];
            if (!success) {
                *rollback = YES;
                breakFlag = YES;
                return;
            }
            
            progress.completedUnitCount++;
            if (progressBlock) {
                [progress setUserInfoObject:@(migrationVersion) forKey:SAMCMigrationManagerProgressVersionUserInfoKey];
                [progress setUserInfoObject:migration forKey:SAMCMigrationManagerProgressMigrationUserInfoKey];
                progressBlock(progress);
                if (progress.cancelled) {
                    success = NO;
                    
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Migration was halted due to cancellation." };
                    if (error) {
                        *error = [NSError errorWithDomain:SAMCMigrationManagerErrorDomain code:SAMCMigrationManagerErrorMigrationCancelled userInfo:userInfo];
                    }
                    *rollback = YES;
                    breakFlag = YES;
                    return;
                }
            }
        }];
        
        if (breakFlag) {
            break;
        }
    }
    return success;
}

- (void)addMigrationsAndSortByVersion:(NSArray *)migrations
{
    [self.externalMigrations addObjectsFromArray:migrations];
    
    // Append to the existing list if already computed
    if (_migrations) {
        NSMutableArray *currentMigrations = [_migrations mutableCopy];
        [currentMigrations addObjectsFromArray:migrations];
        _migrations = [currentMigrations sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"version" ascending:YES] ]];
    }
}

@end
