//
//  SAMCUserInfo.h
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAMCSPBasicInfo.h"

@class SAMCSamProsInfo;

@interface SAMCUserInfo : NSObject

@property (nonatomic, assign) NSInteger uniqueId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, assign) SAMCUserType usertype;
@property (nonatomic, assign) NSTimeInterval lastupdate;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *avatarOriginal;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *cellPhone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) SAMCSamProsInfo *spInfo;

+ (instancetype)userInfoFromDict:(NSDictionary *)infoDict;

- (SAMCSPBasicInfo *)spBasicInfo;

@end

@interface SAMCSamProsInfo : NSObject

@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *serviceCategory;
@property (nonatomic, copy) NSString *serviceDescription;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *address;

+ (instancetype)spInfoFromDict:(NSDictionary *)spInfoDict;

@end