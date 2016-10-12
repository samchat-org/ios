//
//  SAMCSelectLocationViewController.h
//  SamChat
//
//  Created by HJ on 10/12/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCSelectLocationViewController : UIViewController

@property (nonatomic, copy) void(^selectBlock)(NSDictionary *location, BOOL isCurrentLocation);

@end
