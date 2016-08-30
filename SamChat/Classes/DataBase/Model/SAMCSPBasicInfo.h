//
//  SAMCSPBasicInfo.h
//  SamChat
//
//  Created by HJ on 8/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCSPBasicInfo : NSObject

@property (nonatomic, assign) NSInteger uniqueId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) BOOL blockTag;
@property (nonatomic, assign) BOOL favouriteTag;
@property (nonatomic, copy) NSString *spServiceCategory;

+ (instancetype)infoOfUser:(NSInteger)uniqueId
                  username:(NSString *)username
                    avatar:(NSString *)avatar
                  blockTag:(BOOL)blockTag
              favouriteTag:(BOOL)favouriteTag
                  category:(NSString *)category;

@end
