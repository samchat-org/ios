//
//  SAMCTabViewController.h
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCPreferenceManager.h"

@protocol SAMCSwitchUserModeDelegate <NSObject>

- (void)switchToUserMode:(SAMCUserModeType)userMode completion:(void(^)())completion;

@end

@interface SAMCTabViewController : UIViewController

@property (nonatomic, assign) SAMCUserModeType currentUserMode;
@property (nonatomic, weak) id<SAMCSwitchUserModeDelegate> delegate;

@end