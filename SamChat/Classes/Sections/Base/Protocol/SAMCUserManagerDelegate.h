//
//  SAMCUserManagerDelegate.h
//  SamChat
//
//  Created by HJ on 10/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SAMCUser;
@protocol SAMCUserManagerDelegate <NSObject>

@optional
- (void)onUserInfoChanged:(SAMCUser *)user;
- (void)didAddContact:(SAMCUser *)user type:(SAMCContactListType)type;
- (void)didRemoveContact:(SAMCUser *)user type:(SAMCContactListType)type;

@end

NS_ASSUME_NONNULL_END