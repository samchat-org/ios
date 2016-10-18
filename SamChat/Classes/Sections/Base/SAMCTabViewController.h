//
//  SAMCTabViewController.h
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCPreferenceManager.h"

@interface SAMCTabViewController : UIViewController

@property (nonatomic, assign) SAMCUserModeType currentUserMode;

- (void)touchSwitchUserMode:(id)sender;

@end