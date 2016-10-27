//
//  TeamCardOperationItem.m
//  NIM
//
//  Created by chris on 15/3/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMTeamCardOperationItem.h"

@interface NIMTeamCardOperationItem()

@property(nonatomic,assign) NIMKitCardHeaderOpeator opera;

@end

@implementation NIMTeamCardOperationItem

- (instancetype)initWithOperation:(NIMKitCardHeaderOpeator)opera{
    self = [self init];
    if (self) {
        [self buildWithTeamCardOperation:opera];
    }
    return self;
}

- (void)buildWithTeamCardOperation:(NIMKitCardHeaderOpeator)opera{
    _opera = opera;
    switch (opera) {
        case CardHeaderOpeatorAdd:
            _title          = @"Add";
            _imageNormal    = [UIImage imageNamed:@"icon_add_normal"];
            _imageHighLight = [UIImage imageNamed:@"icon_add_pressed"];
            break;
        case CardHeaderOpeatorRemove:
            _title          = @"Remove";
            _imageNormal    = [UIImage imageNamed:@"icon_remove_normal"];
            _imageHighLight = [UIImage imageNamed:@"icon_remove_pressed"];
            break;
        default:
            break;
    }
}

@end
