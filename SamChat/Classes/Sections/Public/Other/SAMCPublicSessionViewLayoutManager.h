//
//  SAMCPublicSessionViewLayoutManager.h
//  SamChat
//
//  Created by HJ on 10/20/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCPublicInputView.h"

@interface SAMCPublicSessionViewLayoutManager : NSObject

@property (nonatomic, assign) CGRect viewRect;

@property (nonatomic, weak) id<NIMInputDelegate> delegate;

- (instancetype)initWithInputView:(SAMCPublicInputView *)inputView tableView:(UITableView*)tableview;

- (void)insertTableViewCellAtRows:(NSArray*)addIndexs animated:(BOOL)animated;

- (void)updateCellAtIndex:(NSInteger)index model:(NIMMessageModel *)model;

-(void)deleteCellAtIndexs:(NSArray*)delIndexs;

-(void)reloadData;

@end
