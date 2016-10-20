//
//  SAMCSPRequestListCell.h
//  SamChat
//
//  Created by HJ on 10/20/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCQuestionSession.h"

@interface SAMCSPRequestListCell : UITableViewCell

- (void)updateWithSession:(SAMCQuestionSession *)questionSession;

@end
