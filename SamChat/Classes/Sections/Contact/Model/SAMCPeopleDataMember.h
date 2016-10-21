//
//  SAMCPeopleDataMember.h
//  SamChat
//
//  Created by HJ on 10/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESGroupedDataCollection.h"
#import "SAMCPeopleInfo.h"

@interface SAMCPeopleDataMember : NSObject<NTESGroupMemberProtocol>

@property (nonatomic, strong) SAMCPeopleInfo *info;

@end
