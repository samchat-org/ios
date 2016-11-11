//
//  SAMCPreferenceManager.h
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCStateDateInfo.h"

@interface SAMCPreferenceManager : NSObject

@property (nonatomic, strong) NSNumber *currentUserMode;
@property (nonatomic, copy) NSString *getuiBindedAlias;
@property (nonatomic, strong) NSNumber *sendClientIdFlag;

@property (nonatomic, copy) NSString *localServicerListVersion;
@property (nonatomic, copy) NSString *localCustomerListVersion;
@property (nonatomic, copy) NSString *localFollowListVersion;

@property (nonatomic, strong) NSNumber *needQuestionNotify;
@property (nonatomic, strong) NSNumber *needSound;
@property (nonatomic, strong) NSNumber *needVibrate;

+ (instancetype)sharedManager;
- (void)reset;

@end
