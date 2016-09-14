//
//  SAMCSPBasicInfo.h
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCSPBasicInfo : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) BOOL blockTag;
@property (nonatomic, assign) BOOL favouriteTag;
@property (nonatomic, copy) NSString *spServiceCategory;

+ (instancetype)infoOfUser:(NSString *)userId
                  username:(NSString *)username
                    avatar:(NSString *)avatar
                  blockTag:(BOOL)blockTag
              favouriteTag:(BOOL)favouriteTag
                  category:(NSString *)category;

@end
