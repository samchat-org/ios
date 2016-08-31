//
//  SAMCUserInfoDB.m
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfoDB.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCUserInfoDB_2016082201.h"

@implementation SAMCUserInfoDB

- (instancetype)init
{
    self = [super initWithName:@"userinfo.db"];
    if (self) {
        [self createMigrationInfo];
    }
    return self;
}

#pragma mark - Create DB
- (void)createMigrationInfo
{
    self.migrationManager = [SAMCMigrationManager managerWithDatabaseQueue:self.queue];
    NSArray *migrations = @[[SAMCUserInfoDB_2016082201 new]];
    [self.migrationManager addMigrations:migrations];
    if (![self.migrationManager hasMigrationsTable]) {
        [self.migrationManager createMigrationsTable:NULL];
    }
}

- (void)updateUser:(SAMCUserInfo *)userInfo
{
    DDLogDebug(@"userInfo: %@", userInfo);
    NSNumber *unique_id = userInfo.uniqueId;
    if (unique_id == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM userinfo WHERE unique_id = ?", unique_id];
        
        NSString *username = userInfo.username;
        NSString *countrycode = userInfo.countryCode;
        NSString *cellphone = userInfo.cellPhone;
        NSString *email = userInfo.email;
        NSString *address = userInfo.address;
        NSNumber *usertype = userInfo.usertype;
        NSString *avatar = userInfo.avatar;
        NSString *avatar_original = userInfo.avatarOriginal;
        NSNumber *lastupdate = userInfo.lastupdate;
        NSString *sp_company_name = userInfo.spInfo.companyName;
        NSString *sp_service_category = userInfo.spInfo.serviceCategory;
        NSString *sp_service_description = userInfo.spInfo.serviceDescription;
        NSString *sp_countrycode = userInfo.spInfo.countryCode;
        NSString *sp_phone = userInfo.spInfo.phone;
        NSString *sp_address = userInfo.spInfo.address;
        
        if ([s next]) {
            username = username ?:[s stringForColumn:@"username"];
            countrycode = countrycode ?:[s stringForColumn:@"countrycode"];
            cellphone = cellphone ?:[s stringForColumn:@"cellphone"];
            email = email ?:[s stringForColumn:@"email"];
            address = address ?:[s stringForColumn:@"address"];
            usertype = usertype ?:@([s intForColumn:@"usertype"]);
            avatar = avatar ?:[s stringForColumn:@"avatar"];
            avatar_original = avatar_original ?:[s stringForColumn:@"avatar_original"];
            lastupdate = lastupdate ?:@([s longForColumn:@"lastupdate"]);
            sp_company_name = sp_company_name ?:[s stringForColumn:@"sp_company_name"];
            sp_service_category = sp_service_category ?:[s stringForColumn:@"sp_service_category"];
            sp_service_description = sp_service_description ?:[s stringForColumn:@"sp_service_description"];
            sp_countrycode = sp_countrycode ?:[s stringForColumn:@"sp_countrycode"];
            sp_phone = sp_phone ?:[s stringForColumn:@"sp_phone"];
            sp_address = sp_address ?:[s stringForColumn:@"sp_address"];
            [db executeUpdate:@"UPDATE userinfo SET username=?, usertype=?, lastupdate=?, avatar=?, avatar_original=?, countrycode=?, \
             cellphone=?, email=?, address=?, sp_company_name=?, sp_service_category=?, sp_service_description=?, \
             sp_countrycode=?, sp_phone=?, sp_address=? WHERE unique_id = ?", username, usertype, lastupdate, avatar, avatar_original,
             countrycode, cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode,
             sp_phone, sp_address, unique_id];
        } else {
            [db executeUpdate:@"INSERT INTO userinfo(unique_id, username, usertype, lastupdate, avatar, avatar_original, countrycode, \
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address) \
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", unique_id, username, usertype, lastupdate, avatar, avatar_original, countrycode,
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address];
        }
        [s close];
    }];
}


@end
