//
//  SAMCPhone.m
//  SamChat
//
//  Created by HJ on 10/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPhone.h"
#import "SAMCServerAPIMacro.h"

@implementation SAMCPhone

+ (SAMCPhone *)phoneWithCountryCode:(NSString *)countryCode cellphone:(NSString *)cellphone
{
    SAMCPhone *phone = [[SAMCPhone alloc] init];
    phone.countryCode = countryCode;
    phone.cellphone = cellphone;
    return phone;
}

- (NSDictionary *)toServerDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([_countryCode length]) {
        [dict setValue:_countryCode forKey:SAMC_COUNTRYCODE];
    }
    if ([_cellphone length]) {
        [dict setValue:_cellphone forKey:SAMC_CELLPHONE];
    }
    return dict;
}

@end
