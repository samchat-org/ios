//
//  UIButton+SAMC.m
//  SamChat
//
//  Created by HJ on 8/17/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "UIButton+SAMC.h"

@implementation UIButton (SAMC)

- (void)startWithCountDownSeconds:(NSInteger)seconds title:(NSString *)title
{
    NSString *preTitle = self.titleLabel.text;
    __block NSInteger timeRemain = seconds;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(timer, ^{
        if (timeRemain <= 1) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself setTitle:preTitle forState:UIControlStateNormal];
            });
        } else {
            timeRemain --;
            dispatch_async(dispatch_get_main_queue(),^{
                [wself setTitle:[NSString stringWithFormat:@"%@(%02lds)",title,timeRemain] forState:UIControlStateNormal];
            });
        }
    });
    dispatch_resume(timer);
}

@end
