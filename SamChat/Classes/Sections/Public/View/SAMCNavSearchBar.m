//
//  SAMCNavSearchBar.m
//  SamChat
//
//  Created by HJ on 10/11/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCNavSearchBar.h"

@implementation SAMCNavSearchBar

- (void)setFrame:(CGRect)frame
{
//    DDLogDebug(@"frame: %@", NSStringFromCGRect(frame));
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, self.superview.frame.size.width-frame.origin.x*2, frame.size.height)];
}

@end
