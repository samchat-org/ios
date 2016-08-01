//
//  SAMCPreferenceManager.h
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SAMCUserModeType) {
    SAMCUserModeTypeCustom,
    SAMCUserModeTypeSP
};

@interface SAMCPreferenceManager : NSObject

@property (nonatomic, assign) NSNumber *currentUserMode;

+ (instancetype)sharedManager;

@end
