//
//  SAMCPublicManager.h
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SAMCPublicManager : NSObject

+ (instancetype)sharedManager;

- (void)searchPublicWithKey:(NSString * __nullable)key
                   location:(NSDictionary * __nullable)location
                 completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion;

- (void)follow:(BOOL)isFollow
officialAccount:(NSNumber *)uniqueId
    completion:(void (^)(NSError * __nullable error))completion;

- (void)queryFollowListIfNecessary;

@end
NS_ASSUME_NONNULL_END