//
//  SAMCPlaceInfo.h
//  SamChat
//
//  Created by HJ on 9/20/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCPlaceInfo : NSObject

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *placeId;

+ (instancetype)placeInfoFromDict:(NSDictionary *)dict;

@end
