//
//  SAMCDataManager.h
//  SamChat
//
//  Created by HJ on 9/6/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCDataManager : NSObject<NIMKitDataProvider>

+ (instancetype)sharedManager;

@property (nonatomic,strong) UIImage *defaultUserAvatar;

@property (nonatomic,strong) UIImage *defaultTeamAvatar;

@end
