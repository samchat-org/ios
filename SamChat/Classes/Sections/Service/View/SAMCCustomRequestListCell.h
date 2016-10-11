//
//  SAMCCustomRequestListCell.h
//  SamChat
//
//  Created by HJ on 8/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCQuestionSession.h"

@interface SAMCCustomRequestListCell : UITableViewCell

- (void)updateWithSession:(SAMCQuestionSession *)questionSession;

@end
