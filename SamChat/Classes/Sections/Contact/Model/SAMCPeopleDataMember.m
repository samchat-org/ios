//
//  SAMCPeopleDataMember.m
//  SamChat
//
//  Created by HJ on 10/21/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPeopleDataMember.h"
#import "NTESSpellingCenter.h"

@implementation SAMCPeopleDataMember

- (NSString *)groupTitle
{
    NSString *title = [[NTESSpellingCenter sharedCenter] firstLetter:[self sortString]].capitalizedString;
    unichar character = [title characterAtIndex:0];
    if (character >= 'A' && character <= 'Z') {
        return title;
    }else{
        return @"#";
    }
}

- (NSString *)memberId
{
    return [NSString stringWithFormat:@"%@ %@", _info.firstName, _info.lastName];
}

- (id)sortKey
{
    return [[NTESSpellingCenter sharedCenter] spellingForString:[self sortString]].shortSpelling;
}

- (NSString *)sortString
{
    return [_info.lastName length] ? _info.lastName : _info.firstName;
}

@end
