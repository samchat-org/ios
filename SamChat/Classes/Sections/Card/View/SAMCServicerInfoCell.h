//
//  SAMCServicerInfoCell.h
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCUser.h"

@interface SAMCServicerInfoCell : UITableViewCell

- (void)refreshData:(SAMCUser *)user;

@end
