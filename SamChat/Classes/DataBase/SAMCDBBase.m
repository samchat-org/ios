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
}

@end
