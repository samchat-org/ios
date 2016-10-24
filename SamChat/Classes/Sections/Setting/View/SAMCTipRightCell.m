//
//  SAMCTipRightCell.m
//  SamChat
//
//  Created by HJ on 10/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCTipRightCell.h"

@implementation SAMCTipRightCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _tipRightLabel = [[UILabel alloc] init];
        _tipRightLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipRightLabel.textColor = UIColorFromRGBA(SAMC_COLOR_RGB_INK, 0.5);
        _tipRightLabel.textAlignment = NSTextAlignmentRight;
        _tipRightLabel.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:_tipRightLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_tipRightLabel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:-35.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_tipRightLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }
    return self;
}


@end
