//
//  SAMCQuestionManager.h
//  SamChat
//
//  Created by HJ on 8/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SAMCQuestionManager : NSObject

+ (instancetype)sharedManager;

- (void)sendQuestion:(NSString *)question
            location:(NSDictionary *)location
          completion:(void (^)(NSError * __nullable error))completion;

@end

NS_ASSUME_NONNULL_END
