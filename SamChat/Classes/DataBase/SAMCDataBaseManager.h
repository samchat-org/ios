//
//  SAMCDataBaseManager.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCDataBaseManager : NSObject

+ (instancetype)sharedManager;
- (void)open;
- (void)close;

@end
