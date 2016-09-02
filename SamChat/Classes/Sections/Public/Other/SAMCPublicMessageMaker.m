//
//  SAMCPublicMessageMaker.m
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMessageMaker.h"

@implementation SAMCPublicMessageMaker

+ (SAMCPublicMessage *)msgWithText:(NSString*)text
{
    SAMCPublicMessage *textMessage = [[SAMCPublicMessage alloc] init];
    textMessage.text = text;
    return textMessage;
}

@end
