//
//  SAMCSessionMessageDataProvider.h
//  SamChat
//
//  Created by HJ on 8/8/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCSession.h"

@interface SAMCSessionMessageDataProvider : NSObject<NIMKitMessageProvider>

- (instancetype)initWithSession:(SAMCSession *)samcsession;

@end
