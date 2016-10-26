//
//  SAMCTableCellFactory.h
//  SamChat
//
//  Created by HJ on 10/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCCommonSwitcherCell.h"
#import "SAMCOptionPortraitCell.h"
#import "SAMCServicerInfoCell.h"
#import "SAMCCustomContactCell.h"
#import "SAMCSPContactCell.h"
#import "SAMCTipRightCell.h"
#import "SAMCMemberGroupCell.h"

@interface SAMCTableCellFactory : NSObject

+ (UITableViewCell *)commonBasicCell:(UITableView *)tableView
                       accessoryType:(UITableViewCellAccessoryType)accessoryType;
+ (UITableViewCell *)commonDetailCell:(UITableView *)tableView
                        accessoryType:(UITableViewCellAccessoryType)accessoryType;
+ (SAMCCommonSwitcherCell *)commonSwitcherCell:(UITableView *)tableView;
+ (SAMCOptionPortraitCell *)optionPortraitCell:(UITableView *)tableView;
+ (SAMCServicerInfoCell *)servicerInfoCell:(UITableView *)tableView;
+ (SAMCCustomContactCell *)customContactCell:(UITableView *)tableView;
+ (SAMCSPContactCell *)spContactCell:(UITableView *)tableView;
+ (SAMCTipRightCell *)tipRightCell:(UITableView *)tabeleView
                     accessoryType:(UITableViewCellAccessoryType)accessoryType;
+ (SAMCMemberGroupCell *)memberGroupCell:(UITableView *)tableView;

@end
