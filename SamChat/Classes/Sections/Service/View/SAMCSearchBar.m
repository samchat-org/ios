//
//  SAMCSearchBar.m
//  SamChat
//
//  Created by HJ on 11/15/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCSearchBar.h"

@implementation SAMCSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xF9F9F9);
        for (UIView* subview in [[self.subviews lastObject] subviews]) {
            if ([subview isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField*)subview;
                [textField setBackgroundColor:SAMC_COLOR_LIGHTGREY];
            }
        }
    }
    return self;
}

@end
