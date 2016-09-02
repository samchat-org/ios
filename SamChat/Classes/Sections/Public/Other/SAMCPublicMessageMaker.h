//
//  SAMCPublicMessageMaker.h
//  SamChat
//
//  Created by HJ on 9/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCPublicMessage.h"

@interface SAMCPublicMessageMaker : NSObject

+ (SAMCPublicMessage *)msgWithText:(NSString*)text;

@end
