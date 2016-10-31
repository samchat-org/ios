//
//  SAMCDBBase.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "FMDatabaseAdditions.h"
#import "SAMCMigrationManager.h"

@interface SAMCDBBase : NSObject

@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) SAMCMigrationManager *migrationManager;

- (instancetype)initWithName:(NSString *)name;

- (BOOL)needsMigration;

- (BOOL)doMigration;

- (BOOL)isTableExists:(NSString *)tableName;

@end
