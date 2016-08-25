//
//  SAMCRequestDetailInfoView.m
//  SamChat
//
//  Created by HJ on 8/2/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCRequestDetailInfoView.h"

@interface SAMCRequestDetailInfoView ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) SAMCQuestionSession *questionSession;

@end

@implementation SAMCRequestDetailInfoView

- (instancetype)initWithQuestionSession:(SAMCQuestionSession *)questionSession
{
    self = [super init];
    if (self) {
        _questionSession = questionSession;
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = UIColorFromRGB(0xFCFCFC);
    _avatarView = [[UIImageView alloc] init];
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarView.backgroundColor = [UIColor redColor];
    [self addSubview:_avatarView];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _infoLabel.backgroundColor = [UIColor greenColor];
    _infoLabel.textColor = UIColorFromRGB(0x666666);
    _infoLabel.font = [UIFont systemFontOfSize:17.0f];
    _infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _infoLabel.numberOfLines = 0;
    _infoLabel.text = _questionSession.question;
    [self addSubview:_infoLabel];
    
    _locationLabel = [[UILabel alloc] init];
    _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _locationLabel.backgroundColor = [UIColor purpleColor];
    _locationLabel.textColor = UIColorFromRGB(0xA7A7A7);
    _locationLabel.font = [UIFont systemFontOfSize:12.0f];
    _locationLabel.text = _questionSession.address;
    [self addSubview:_locationLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_avatarView(50)]-10-[_infoLabel]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_infoLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarView]-10-[_locationLabel]-20-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView,_locationLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_avatarView(50)]-(>=5)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_avatarView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_infoLabel]-5-[_locationLabel]-5-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_infoLabel,_locationLabel)]];
}

@end
