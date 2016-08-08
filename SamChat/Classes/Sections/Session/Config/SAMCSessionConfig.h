//
//  SAMCSessionConfig.h
//  SamChat
//
//  Created by HJ on 8/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESSessionConfig.h"

@interface SAMCSessionConfig : NTESSessionConfig

@property (nonatomic, assign) SAMCUserModeType userMode;

- (instancetype)initWithSession:(NIMSession *)session userMode:(SAMCUserModeType)userMode;

@end
