//
//  SAMCUnreadCountManagerDelegate.h
//  SamChat
//
//  Created by HJ on 9/16/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAMCUnreadCountManagerDelegate <NSObject>

@optional
- (void)chatUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode;
- (void)serviceUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode;
- (void)publicUnreadCountDidChanged:(NSInteger)count mode:(SAMCUserModeType)mode;

@end

NS_ASSUME_NONNULL_END