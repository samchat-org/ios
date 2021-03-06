//
//  SAMCDataBaseManager.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCMessageDB.h"
#import "SAMCUserInfoDB.h"
#import "SAMCQuestionDB.h"
#import "SAMCPublicDB.h"

@interface SAMCDataBaseManager : NSObject

@property (nonatomic, strong) SAMCMessageDB *messageDB;
@property (nonatomic, strong) SAMCUserInfoDB *userInfoDB;
@property (nonatomic, strong) SAMCQuestionDB *questionDB;
@property (nonatomic, strong) SAMCPublicDB *publicDB;

+ (instancetype)sharedManager;
- (void)open;
- (void)close;
- (BOOL)needsMigration;
- (BOOL)doMigration;

- (void)doMigrationCompletion:(void (^)(BOOL success))completion;

@end
