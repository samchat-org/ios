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
    self.queue = [FMDatabaseQueue databaseQueueWithPath:filepath];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSArray *sqls = @[@"create table if not exists notifications(serial integer primary key, \
                          timetag integer,sender text,receiver text,content text,status integer)",
                          @"create index if not exists readindex on notifications(status)",
                          @"create index if not exists timetagindex on notifications(timetag)"];
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,db.lastError);
            }
        }
    }];
}

@end
