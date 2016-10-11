//
//  SAMCResponseAvatarsView.h
//  SamChat
//
//  Created by HJ on 10/10/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCResponseAvatarsView : UIView

- (void)updateAvatars:(NSArray<NIMKitInfo *> *)infos;

@end
