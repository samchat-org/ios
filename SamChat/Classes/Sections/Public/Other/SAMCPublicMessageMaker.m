//
//  SAMCPublicMessageMaker.m
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCPublicMessageMaker.h"
#import "SAMCPublicSession.h"
#import "SAMCImageAttachment.h"

@implementation SAMCPublicMessageMaker

+ (SAMCPublicMessage *)msgWithText:(NSString*)text
{
    SAMCPublicMessage *textMessage = [[SAMCPublicMessage alloc] init];
    textMessage.messageType = NIMMessageTypeText;
    textMessage.text = text;
    return textMessage;
}

+ (SAMCPublicMessage *)msgWithImage:(UIImage *)image
{
    SAMCPublicMessage *imageMessage = [[SAMCPublicMessage alloc] init];
    imageMessage.messageType = NIMMessageTypeCustom;
    NIMCustomObject *customObject = [[NIMCustomObject alloc] init];
    SAMCImageAttachment *attachment = [[SAMCImageAttachment alloc] initWithImage:image];
    customObject.attachment = attachment;
    imageMessage.messageObject = customObject;
    return imageMessage;
}



@end
