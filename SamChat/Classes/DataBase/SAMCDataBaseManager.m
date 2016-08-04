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
    _messageDB = [[SAMCMessageDB alloc] init];
}

- (void)close
{
    _messageDB = nil;
}

@end
