//
//  SAMCCellButton.m
//  SamChat
//
//  Created by HJ on 11/9/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCellButton.h"

// fix delayed “Touch Down” event for UIButton in UITableViewCell
// is caused by the UIScrollView property delaysContentTouches
@implementation SAMCCellButton

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = YES; }];
}


- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self performSelector:@selector(setDefault) withObject:nil afterDelay:0.1];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self performSelector:@selector(setDefault) withObject:nil afterDelay:0.1];
}


- (void)setDefault
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = NO; }];
}

@end
