//
//  SAMCSPRequestListDelegate.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSPRequestListDelegate.h"
#import "SAMCRequestListCell.h"
#import "SAMCQuestionManager.h"
#import "SAMCQuestionSession.h"

@implementation SAMCSPRequestListDelegate

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellId";
    SAMCRequestListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SAMCRequestListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SAMCQuestionSession *session = [self data][indexPath.row];
    cell.messageLabel.text = session.question;
    cell.leftLabel.text = [session questionTimeDescription];
    cell.middleLabel.text = session.address;
    cell.rightLabel.text = session.senderUsername;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
