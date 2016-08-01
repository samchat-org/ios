//
//  SAMCTabViewController.h
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCPreferenceManager.h"

extern NSString * const SAMCSwitchToUserModeKey;

@interface SAMCTabViewController : UIViewController

@property (nonatomic, assign) SAMCUserModeType currentUserMode;

@end
