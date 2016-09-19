//
//  SAMCResourceManager.h
//  SamChat
//
//  Created by HJ on 9/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCResourceManager : NSObject

+ (instancetype)sharedManager;

- (void)upload:(NSString *)filepath
           key:(NSString *)key
   contentType:(NSString *)contentType
      progress:(void(^)(CGFloat progress))progressBlock
    completion:(void(^)(NSString *urlString, NSError *error))completionBlock;

@end
