//
//  SAMCSettingManager.h
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SAMCSettingManager : NSObject

+ (instancetype)sharedManager;

- (void)createSamPros:(NSDictionary *)info
           completion:(void (^)(NSError * __nullable error))completion;

@end

NS_ASSUME_NONNULL_END