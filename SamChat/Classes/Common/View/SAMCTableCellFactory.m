//
//  SAMCTableCellFactory.m
//  SamChat
//
//  Created by HJ on 10/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTableCellFactory.h"

@implementation SAMCTableCellFactory

+ (UITableViewCell *)commonBasicCell:(UITableView *)tableView accessoryType:(UITableViewCellAccessoryType)accessoryType
{
    static NSString * cellId = @"SAMCCommonBasicCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        cell.textLabel.textColor = SAMC_COLOR_INK;
    }
    cell.accessoryType = accessoryType;
    return cell;
}

+ (UITableViewCell *)commonDetailCell:(UITableView *)tableView accessoryType:(UITableViewCellAccessoryType)accessoryType
{
    static NSString * cellId = @"SAMCCommonDetailCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
        cell.detailTextLabel.textColor = SAMC_COLOR_INK;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return cell;
}

+ (SAMCCommonSwitcherCell *)commonSwitcherCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCCommonSwitcherCellId";
    SAMCCommonSwitcherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCCommonSwitcherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textColor = SAMC_COLOR_INK;
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    return cell;
}

+ (SAMCOptionPortraitCell *)optionPortraitCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCOptionPortraitCellId";
    SAMCOptionPortraitCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCOptionPortraitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

+ (SAMCServicerInfoCell *)servicerInfoCell:(UITableView *)tableView
{
    static NSString * cellId = @"SAMCServicerInfoCellId";
    SAMCServicerInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCServicerInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

@end
