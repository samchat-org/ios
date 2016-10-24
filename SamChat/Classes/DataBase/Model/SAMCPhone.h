//
//  SAMCPhone.h
//  SamChat
//
//  Created by HJ on 10/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCPhone : NSObject

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *cellphone;

+ (SAMCPhone *)phoneWithCountryCode:(NSString *)countryCode cellphone:(NSString *)cellphone;
- (NSDictionary *)toServerDictionary;

@end
