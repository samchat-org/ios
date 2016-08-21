//
//  SAMCUserInfoDB.m
//  SamChat
//
//  Created by HJ on 8/19/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCUserInfoDB.h"
#import "SAMCServerAPIMacro.h"

@implementation SAMCUserInfoDB

- (instancetype)init
{
    self = [super initWithName:@"userinfo.db"];
    if (self) {
        [self createDataBaseIfNeccessary];
    }
    return self;
}

#pragma mark - Create DB
- (void)createDataBaseIfNeccessary
{
    // | serial(primary)| unique_id | username | usertype | lastupdate | avatar | avatar_original | countrycode |
    // | cellphone | email | address | sp_company_name | sp_service_category | sp_service_desciption | sp_countrycode |
    // | sp_phone | sp_address |
    [self.queue inDatabase:^(FMDatabase *db) {
        NSArray *sqls = @[@"CREATE TABLE IF NOT EXISTS userinfo(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
                          unique_id INTEGER UNIQUE, username TEXT NOT NULL, usertype INTEGER, lastupdate INTEGER, \
                          avatar TEXT, avatar_original TEXT, countrycode TEXT, cellphone TEXT, \
                          email TEXT, address TEXT, sp_company_name TEXT, sp_service_category TEXT, \
                          sp_service_description TEXT, sp_countrycode TEXT, sp_phone TEXT, sp_address TEXT)",
                          @"CREATE INDEX IF NOT EXISTS unique_id_index ON userinfo(unique_id)",
                          @"CREATE index IF NOT EXISTS username_index ON userinfo(username)"];
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,db.lastError);
            }
        }
    }];
}

- (void)updateUser:(NSDictionary *)userInfo
{
    DDLogDebug(@"userInfo: %@", userInfo);
    NSNumber *unique_id = [userInfo valueForKey:SAMC_ID];
    if (unique_id == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM userinfo WHERE unique_id = ?", unique_id];
        
        NSString *username = [userInfo valueForKey:SAMC_USERNAME];
        NSString *countrycode = [NSString stringWithFormat:@"%@",[userInfo valueForKey:SAMC_COUNTRYCODE]]; 
        NSString *cellphone = [userInfo valueForKey:SAMC_CELLPHONE];
        NSString *email = [userInfo valueForKey:SAMC_EMAIL];
        NSString *address = [userInfo valueForKey:SAMC_ADDRESS];
        NSNumber *usertype = [userInfo valueForKey:SAMC_TYPE];
        NSString *avatar = [userInfo valueForKeyPath:SAMC_AVATAR_THUMB];
        NSString *avatar_original = [userInfo valueForKeyPath:SAMC_AVATAR_ORIGIN];
        NSNumber *lastupdate = [userInfo valueForKey:SAMC_LASTUPDATE];
        NSString *sp_company_name = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_COMPANY_NAME];
        NSString *sp_service_category = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_CATEGORY];
        NSString *sp_service_description = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_DESCRIPTION];
        NSString *sp_countrycode = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_COUNTRYCODE];
        NSString *sp_phone = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_PHONE];
        NSString *sp_address = [userInfo valueForKeyPath:SAMC_SAM_PROS_INFO_ADDRESS];
        
        if ([s next]) {
            username = username ?:[s stringForColumn:@"unique_id"];
            countrycode = countrycode ?:[s stringForColumn:@"countrycode"];
            cellphone = cellphone ?:[s stringForColumn:@"cellphone"];
            email = email ?:[s stringForColumn:@"email"];
            address = address ?:[s stringForColumn:@"address"];
            usertype = usertype ?:@([s intForColumn:@"usertype"]);
            avatar = avatar ?:[s stringForColumn:@"avatar"];
            avatar_original = avatar_original ?:[s stringForColumn:@"avatar_original"];
            lastupdate = lastupdate ?:@([s intForColumn:@"lastupdate"]);
            sp_company_name = sp_company_name ?:[s stringForColumn:@"sp_company_name"];
            sp_service_category = sp_service_category ?:[s stringForColumn:@"sp_service_category"];
            sp_service_description = sp_service_description ?:[s stringForColumn:sp_service_description];
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
