//
//  SAMCPublicMessageDataProvider.h
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCPublicSession.h"

@interface SAMCPublicMessageDataProvider : NSObject<NIMKitMessageProvider>

- (instancetype)initWithSession:(SAMCPublicSession *)session;

@end
