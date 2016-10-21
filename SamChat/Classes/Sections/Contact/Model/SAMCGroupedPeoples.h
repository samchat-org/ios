//
//  SAMCGroupedPeoples.h
//  SamChat
//
//  Created by HJ on 10/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NTESGroupedDataCollection.h"
#import "SAMCPeopleInfo.h"

@interface SAMCGroupedPeoples : NTESGroupedDataCollection

- (instancetype)initWithPeoples:(NSArray<SAMCPeopleInfo *> *)peoples;

@end
