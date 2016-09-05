//
//  SAMCSettingPortraitCell.h
//  SamChat
//
//  Created by HJ on 7/27/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMCommonTableViewCell.h"

#define SAMC_CELL_EXTRA_UID_KEY             @"uid"
#define SAMC_CELL_EXTRA_TOP_ACTION_KEY      @"topAction"
#define SAMC_CELL_EXTRA_BOTTOM_ACTION_KEY   @"bottomAction"
#define SAMC_CELL_EXTRA_TOP_TEXT_KEY        @"topText"
#define SAMC_CELL_EXTRA_BOTTOM_TEXT_KEY     @"bottomText"

@interface SAMCSettingPortraitCell : UITableViewCell<NIMCommonTableViewCell>

@end
