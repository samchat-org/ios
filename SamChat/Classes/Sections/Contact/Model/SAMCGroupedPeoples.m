//
//  SAMCGroupedPeoples.m
//  SamChat
//
//  Created by HJ on 10/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCGroupedPeoples.h"
#import "SAMCPeopleDataMember.h"

@implementation SAMCGroupedPeoples

- (instancetype)initWithPeoples:(NSArray<SAMCPeopleInfo *> *)peoples
{
    self = [super init];
    if(self) {
        self.groupTitleComparator = ^NSComparisonResult(NSString *title1, NSString *title2) {
            if ([title1 isEqualToString:@"#"]) {
                return NSOrderedDescending;
            }
            if ([title2 isEqualToString:@"#"]) {
                return NSOrderedAscending;
            }
            return [title1 compare:title2];
        };
        self.groupMemberComparator = ^NSComparisonResult(NSString *key1, NSString *key2) {
            return [key1 compare:key2];
        };
        [self update:peoples];
    }
    return self;
}

- (void)update:(NSArray *)peoples
{
    NSMutableArray *members = [NSMutableArray array];
    for (SAMCPeopleInfo *info in peoples) {
        SAMCPeopleDataMember *member = [[SAMCPeopleDataMember alloc] init];
        member.info = info;
        [members addObject:member];
    }
    [self setMembers:members];
}

@end
