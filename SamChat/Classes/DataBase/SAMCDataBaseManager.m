//
//  SAMCDataBaseManager.m
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCDataBaseManager.h"

@interface SAMCDataBaseManager ()


@end

@implementation SAMCDataBaseManager

+ (instancetype)sharedManager
{
    static SAMCDataBaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCDataBaseManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)open
{
    if (_messageDB == nil) {
        _messageDB = [[SAMCMessageDB alloc] init];
    }
    if (_userInfoDB == nil) {
        _userInfoDB = [[SAMCUserInfoDB alloc] init];
    }
}

- (void)close
{
    _messageDB = nil;
    _userInfoDB = nil;
}

- (BOOL)needsMigration
{
    if ([_messageDB needsMigration]) {
        return YES;
    }
    if ([_userInfoDB needsMigration]) {
        return YES;
    }
    return NO;
}

- (BOOL)doMigration
{
    [NSThread sleepForTimeInterval:6]; // TODO: for test, delete it later
    if ([_messageDB needsMigration]) {
        if (![_messageDB doMigration]) {
            return false;
        }
    }
    if ([_userInfoDB needsMigration]) {
        if (![_userInfoDB doMigration]) {
            return false;
        }
    }
    return true;
}

@end
