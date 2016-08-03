//
//  SAMCDBBase.h
//  SamChat
//
//  Created by HJ on 8/3/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SAMCDBBase : NSObject

@property (nonatomic, strong) FMDatabaseQueue *queue;

- (instancetype)initWithName:(NSString *)name;

@end
