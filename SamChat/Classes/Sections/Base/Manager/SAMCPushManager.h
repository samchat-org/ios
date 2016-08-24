//
//  SAMCPushManager.h
//  SamChat
//
//  Created by HJ on 8/18/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeTuiSdk.h"

@interface SAMCPushManager : NSObject

+ (instancetype)sharedManager;
- (void)open;
- (void)close;

@end
