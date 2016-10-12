//
//  SAMCPlaceInfo.m
//  SamChat
//
//  Created by HJ on 9/20/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPlaceInfo.h"
#import "SAMCServerAPIMacro.h"

@implementation SAMCPlaceInfo

+ (instancetype)placeInfoFromDict:(NSDictionary *)dict
{
    SAMCPlaceInfo *info = [[SAMCPlaceInfo alloc] init];
    info.desc = dict[SAMC_DESCRIPTION];
    info.placeId = dict[SAMC_PLACE_ID];
    return info;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\r%@\rDescription:%@\rPlaceId:%@", [super description], _desc, _placeId];
}

@end
