//
//  SAMCSessionConfig.h
//  SamChat
//
//  Created by HJ on 8/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESSessionConfig.h"
#import "SAMCSession.h"

@interface SAMCSessionConfig : NTESSessionConfig

@property (nonatomic, assign) SAMCUserModeType userMode;

- (instancetype)initWithSession:(SAMCSession *)session;

@end
