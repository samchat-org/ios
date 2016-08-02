//
//  SAMCSPPublicMsgDataSource.h
//  SamChat
//
//  Created by HJ on 8/1/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SAMCSPPublicMsgDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, readonly) NSInteger messageLimit;
@property (nonatomic, readonly) NSInteger showTimeInterval;

@end
