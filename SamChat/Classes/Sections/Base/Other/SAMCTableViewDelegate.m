//
//  SAMCTableViewDelegate.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTableViewDelegate.h"

@interface SAMCTableViewDelegate ()

@property (nonatomic, copy) NSArray *(^SAMCDataReceiver)(void);

@end

@implementation SAMCTableViewDelegate

- (instancetype) initWithTableData:(NSArray *(^)(void))data viewController:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        _SAMCDataReceiver = data;
        _viewController = controller;
    }
    return self;
}

- (NSArray *)data
{
    return self.SAMCDataReceiver();
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self data] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
