//
//  SAMCDataBaseManager.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCMessageDB.h"


@interface SAMCDataBaseManager : NSObject

@property (nonatomic, strong) SAMCMessageDB *messageDB;

+ (instancetype)sharedManager;
- (void)open;
- (void)close;

@end
