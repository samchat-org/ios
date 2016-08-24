//
//  SAMCPreferenceManager.h
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCPreferenceManager : NSObject

@property (nonatomic, strong) NSNumber *currentUserMode;
@property (nonatomic, copy) NSString *getuiBindedAlias;

+ (instancetype)sharedManager;

@end
