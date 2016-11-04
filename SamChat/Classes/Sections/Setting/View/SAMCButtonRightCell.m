//
//  SAMCButtonRightCell.m
//  SamChat
//
//  Created by HJ on 11/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCButtonRightCell.h"
#import "UIView+NIM.h"

@interface SAMCButtonRightCell ()

@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation SAMCButtonRightCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _rightButton = [[UIButton alloc] init];
        [self addSubview:_rightButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _rightButton.nim_right   = self.nim_width - 35;
    _rightButton.nim_centerY = self.nim_height * .5f;
}

@end
