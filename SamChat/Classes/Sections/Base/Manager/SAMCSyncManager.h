//
//  SAMCSyncManager.h
//  SamChat
//
//  Created by HJ on 9/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCSyncManager : NSObject

@property (nonatomic, strong) NSString *clientId;

+ (instancetype)sharedManager;

- (void)start;
- (void)close;

@end
