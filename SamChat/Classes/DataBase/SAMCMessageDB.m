//
//  SAMCMessageDB.m
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCMessageDB.h"
#import "FMDB.h"
#import "NTESFileLocationHelper.h"

@interface SAMCMessageDB ()


@end

@implementation SAMCMessageDB

- (instancetype)init
{
    self = [super initWithName:@"samcmessage.db"];
    if (self) {
        [self createDataBaseIfNeccessary];
    }
    return self;
}

- (void)createDataBaseIfNeccessary
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSArray *sqls = @[@"create table if not exists sessiontag(id integer primary key autoincrement, \
                          sessionid text, custom integer, sp integer)",
                          @"create index if not exists customindex on sessiontag(custom)",
                          @"create index if not exists spindex on sessiontag(sp)"];
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,db.lastError);
            }
        }
    }];
}

@end
