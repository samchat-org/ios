//
//  SAMCServicerInfoCell.m
//  SamChat
//
//  Created by HJ on 10/13/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCServicerInfoCell.h"

@interface SAMCServicerInfoCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation SAMCServicerInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.nameLabel];
    [self addSubview:self.categoryLabel];
    [self addSubview:self.descLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_nameLabel]"
                                                     options:0
                                                     metrics:nil
                                                       views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_categoryLabel]"
                                                     options:0
                                                     metrics:nil
                                                       views:NSDictionaryOfVariableBindings(_categoryLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_descLabel]-15-|"
                                                     options:0
                                                     metrics:nil
                                                       views:NSDictionaryOfVariableBindings(_descLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_nameLabel][_categoryLabel][_descLabel]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_nameLabel,_categoryLabel,_descLabel)]];
}

- (void)refreshData:(SAMCUser *)user
{
    _nameLabel.text = user.userInfo.username;
    _categoryLabel.text = user.userInfo.spInfo.serviceCategory;
    _descLabel.text = user.userInfo.spInfo.serviceDescription;
}

#pragma mark - lazy load
- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.textColor = UIColorFromRGB(0x172843);
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    return _nameLabel;
}

- (UILabel *)categoryLabel
{
    if (_categoryLabel == nil) {
        _categoryLabel = [[UILabel alloc] init];
        _categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _categoryLabel.textColor = UIColorFromRGB(0x172843);
        _categoryLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _categoryLabel;
}

- (UILabel *)descLabel
{
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _descLabel.numberOfLines = 0;
        _descLabel.textColor = UIColorFromRGB(0x929197);
        _descLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _descLabel;
}

@end
