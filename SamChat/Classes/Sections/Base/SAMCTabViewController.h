//
//  SAMCTabViewController.h
//  SamChat
//
//  Created by HJ on 7/25/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const SAMCSwitchToUserModeKey;
typedef NS_ENUM(NSInteger,SAMCUserModeType) {
    SAMCUserModeTypeCustom,
    SAMCUserModeTypeSP
};

@interface SAMCTabViewController : UIViewController

@end
