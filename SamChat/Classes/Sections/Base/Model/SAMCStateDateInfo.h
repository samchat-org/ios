//
//  SAMCStateDateInfo.h
//  SamChat
//
//  Created by HJ on 9/26/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCStateDateInfo : NSObject

@property (nonatomic, copy) NSString *servicerListVersion;
@property (nonatomic, copy) NSString *customerListVersion;
@property (nonatomic, copy) NSString *followListVersion;

+ (instancetype)stateDateInfoFromDict:(NSDictionary *)dict;

@end
