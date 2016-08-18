//
//  SAMCSettingManager.m
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSettingManager.h"

@implementation SAMCSettingManager

+ (instancetype)sharedManager
{
    static SAMCSettingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAMCSettingManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)createSamPros:(NSDictionary *)info
           completion:(void (^)(NSError * __nullable error))completion
{
}

@end
