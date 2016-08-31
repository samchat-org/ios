//
//  SAMCQuestionManagerDelegate.h
//  SamChat
//
//  Created by HJ on 8/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAMCQuestionSession;

NS_ASSUME_NONNULL_BEGIN

@protocol SAMCQuestionManagerDelegate <NSObject>

@optional
- (void)didAddQuestionSession:(SAMCQuestionSession *)questionSession;

@end

NS_ASSUME_NONNULL_END