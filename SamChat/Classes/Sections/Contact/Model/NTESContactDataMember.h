//
//  NTESContactDataMember.h
//  NIM
//
//  Created by chris on 15/9/21.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESGroupedDataCollection.h"

@interface NTESContactDataMember : NSObject<NTESGroupMemberProtocol>

@property (nonatomic,strong) NIMKitInfo *info;

@end
