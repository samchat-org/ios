//
//  SAMCPublicSearchResultCell.h
//  SamChat
//
//  Created by HJ on 10/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCUser.h"

@protocol SAMCPublicSearchResultDelegate <NSObject>

- (void)follow:(BOOL)isFollow user:(SAMCUser *)user completion:(void(^)(BOOL success))completion;

@end

@interface SAMCPublicSearchResultCell : UITableViewCell

@property (nonatomic, weak) id<SAMCPublicSearchResultDelegate> delegate;
@property (nonatomic, strong) SAMCUser *user;
@property (nonatomic, assign) BOOL isFollowed;

@end
