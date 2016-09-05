//
//  SAMCContactManager.h
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SAMCContactManager : NSObject

+ (instancetype)sharedManager;

- (void)queryFuzzyUserWithKey:(NSString * __nullable)key
                   completion:(void (^)(NSArray * __nullable users, NSError * __nullable error))completion;

- (void)queryContactListIfNecessary;

@end

NS_ASSUME_NONNULL_END
