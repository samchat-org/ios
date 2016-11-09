//
//  SAMCLazyButton.m
//  SamChat
//
//  Created by HJ on 11/9/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCLazyButton.h"

@implementation SAMCLazyButton

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    [super sendAction:action to:target forEvent:event];
    self.userInteractionEnabled = NO;
    
    // After handle UIEvent, block this button UI events for a while.
    [self performSelector:@selector(delayEnable) withObject:nil afterDelay:0.2];
}

- (void)delayEnable
{
    self.userInteractionEnabled = YES;
}

@end
