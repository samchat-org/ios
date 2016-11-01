//
//  SAMCPeopleInfo.m
//  SamChat
//
//  Created by HJ on 10/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPeopleInfo.h"

@implementation SAMCPeopleInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _firstName = @"";
        _middleName = @"";
        _lastName = @"";
        _phone = @"";
    }
    return self;
}

- (void)setFirstName:(NSString *)firstName
{
    _firstName = firstName ?:@"";
}

- (void)setMiddleName:(NSString *)middleName
{
    _middleName = middleName ?:@"";
}

- (void)setLastName:(NSString *)lastName
{
    _lastName = lastName ?:@"";
}

- (void)setPhone:(NSString *)phone
{
    phone = phone ?:@"";
    _phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]"
                                              withString:@""
                                                 options:NSRegularExpressionSearch
                                                   range:NSMakeRange(0, [phone length])];
}

@end
