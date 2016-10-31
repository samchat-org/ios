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
#import "SAMCDataBaseMacro.h"

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

- (SAMCUser *)userInfo:(NSString *)userId
{
    __block SAMCUser *user = [[SAMCUser alloc] init];
    user.userId = userId;
    NSNumber *unique_id = @([userId integerValue]);
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM userInfo WHERE unique_id = ?", unique_id];
        if ([s next]) {
            SAMCUserInfo *userInfo = [[SAMCUserInfo alloc] init];
            userInfo.username = [s stringForColumn:@"username"];
            userInfo.usertype = @([s intForColumn:@"usertype"]);
            userInfo.lastupdate = @([s longForColumn:@"lastupdate"]);
            userInfo.avatar = [s stringForColumn:@"avatar"];
            userInfo.avatarOriginal = [s stringForColumn:@"avatar_original"];
            userInfo.countryCode = [s stringForColumn:@"countrycode"];
            userInfo.cellPhone = [s stringForColumn:@"cellphone"];
            userInfo.email = [s stringForColumn:@"email"];
            userInfo.address = [s stringForColumn:@"address"];
            if ([userInfo.usertype isEqual:@(SAMCuserTypeSamPros)]) {
                SAMCSamProsInfo *spInfo = [[SAMCSamProsInfo alloc] init];
                spInfo.companyName = [s stringForColumn:@"sp_company_name"];
                spInfo.serviceCategory = [s stringForColumn:@"sp_service_category"];
                spInfo.serviceDescription = [s stringForColumn:@"sp_service_description"];
                spInfo.countryCode = [s stringForColumn:@"sp_countrycode"];
                spInfo.phone = [s stringForColumn:@"sp_phone"];
                spInfo.address = [s stringForColumn:@"sp_address"];
                spInfo.email = [s stringForColumn:@"sp_email"];
                userInfo.spInfo = spInfo;
            }
            user.userInfo = userInfo;
        }
        [s close];
    }];
    return user;
}

- (void)updateUser:(SAMCUser *)user
{
    DDLogDebug(@"updateUser: %@", user);
    if (user.userId == nil) {
        DDLogError(@"unique id should not be nil");
        return;
    }
    NSNumber *unique_id = @([user.userId integerValue]);
    SAMCUserInfo *userInfo = user.userInfo;
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
        NSString *sp_email = userInfo.spInfo.email;
        
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
            sp_email = sp_email ?:[s stringForColumn:@"sp_email"];
            [db executeUpdate:@"UPDATE userinfo SET username=?, usertype=?, lastupdate=?, avatar=?, avatar_original=?, countrycode=?, \
             cellphone=?, email=?, address=?, sp_company_name=?, sp_service_category=?, sp_service_description=?, \
             sp_countrycode=?, sp_phone=?, sp_address=?, sp_email=? WHERE unique_id = ?", username, usertype, lastupdate, avatar, avatar_original,
             countrycode, cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode,
             sp_phone, sp_address, sp_email, unique_id];
        } else {
            [db executeUpdate:@"INSERT INTO userinfo(unique_id, username, usertype, lastupdate, avatar, avatar_original, countrycode, \
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address, sp_email) \
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", unique_id, username, usertype, lastupdate, avatar, avatar_original, countrycode,
             cellphone, email, address, sp_company_name, sp_service_category, sp_service_description, sp_countrycode, sp_phone, sp_address, sp_email];
        }
        [s close];
    }];
}

- (BOOL)updateContactList:(NSArray *)users type:(SAMCContactListType)listType;
{
    DDLogDebug(@"update %@ list: %@", listType==SAMCContactListTypeServicer?@"servicer":@"customer", users);
    if (![self resetContactListTable:(SAMCContactListType)listType]) {
        return NO;
    }
    if ((users == nil) || ([users count] <= 0)) {
        return true;
    }
    __block BOOL result = YES;
    // TODO: separate transaction?
//    {
//        
//        “id”: unique_id_in_samchat
//        “username”: ”Kevin Dong”
//        “lastupdate”: 123
//        “type”:[0/1]  0:user  1:Sam-pros
//        ”avatar”: // option
//        {
//            “thumb:” http://121.42.207.185/avatar/2016/1/18/thumb_145312348.png
//        }
//        “sam_pros_info”:{
//            “service_category”:“fast food”
//            
//        }]
//    }
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSDictionary *user in users) {
            NSNumber *unique_id = user[SAMC_ID];
            NSString *username = user[SAMC_USERNAME];
            NSNumber *usertype = user[SAMC_TYPE];
            NSNumber *lastupdate = user[SAMC_LASTUPDATE];
            NSString *avatar = [user valueForKeyPath:SAMC_AVATAR_THUMB];
            NSString *sp_service_category = [user valueForKeyPath:SAMC_SAM_PROS_INFO_SERVICE_CATEGORY];
            
            FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM userinfo WHERE unique_id = ?", unique_id];
            if ([s next] && ([s intForColumnIndex:0]>0)) {
                result = [db executeUpdate:@"UPDATE userinfo SET username=?, usertype=?, lastupdate=?, avatar=?, sp_service_category=? WHERE unique_id=?",username,usertype,lastupdate,avatar,sp_service_category,unique_id];
            } else {
                result = [db executeUpdate:@"INSERT INTO userinfo(unique_id, username, usertype, lastupdate, avatar, sp_service_category) VALUES (?,?,?,?,?,?)", unique_id,username,usertype,lastupdate,avatar,sp_service_category];
            }
            [s close];
            if (result == NO) {
                *rollback = YES;
                break;
            }
            if (listType == SAMCContactListTypeCustomer) {
                result = [db executeUpdate:@"INSERT OR IGNORE INTO contact_list_customer(unique_id) VALUES(?)",unique_id];
            } else if (listType == SAMCContactListTypeServicer){
                result = [db executeUpdate:@"INSERT OR IGNORE into contact_list_servicer(unique_id) VALUES(?)",unique_id];
            }
            if (result == NO) {
                *rollback = YES;
                break;
            }
        }
    }];
    return result;
}

- (void)insertToContactList:(SAMCUser *)user type:(SAMCContactListType)listType
{
    if (user == nil) {
        return;
    }
    [self updateUser:user];
    NSString *tableName;
    if (listType == SAMCContactListTypeCustomer) {
        tableName = @"contact_list_customer";
    } else {
        tableName = @"contact_list_servicer";
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            DDLogError(@"insertToContactList table %@ not exists", tableName);
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(unique_id) VALUES(?)", tableName];
        [db executeUpdate:sql, @([user.userId integerValue])];
    }];
}

- (void)deleteFromContactList:(SAMCUser *)user type:(SAMCContactListType)listType
{
    if (user == nil) {
        return;
    }
    NSString *tableName;
    if (listType == SAMCContactListTypeCustomer) {
        tableName = @"contact_list_customer";
    } else {
        tableName = @"contact_list_servicer";
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            DDLogError(@"deleteFromContactList table %@ not exists", tableName);
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE unique_id=?", tableName];
        [db executeUpdate:sql, @([user.userId integerValue])];
    }];
}

- (NSArray<NSString *> *)myContactListOfType:(SAMCContactListType)listType
{
    NSString *tableName;
    if (listType == SAMCContactListTypeCustomer) {
        tableName = @"contact_list_customer";
    } else {
        tableName = @"contact_list_servicer";
    }
    __block NSMutableArray *contactList = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            DDLogError(@"myContactListOfType table %@ not exists", tableName);
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"select * from %@", tableName];
        FMResultSet *s = [db executeQuery:sql];
        while ([s next]) {
            NSNumber *uniqueId = @([s longForColumn:@"unique_id"]);
            [contactList addObject:uniqueId.stringValue];
        }
        [s close];
    }];
    return contactList;
}

- (BOOL)isUser:(NSString *)userId inMyContactListOfType:(SAMCContactListType)listType
{
    NSString *tableName;
    if (listType == SAMCContactListTypeCustomer) {
        tableName = @"contact_list_customer";
    } else {
        tableName = @"contact_list_servicer";
    }
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            DDLogError(@"isUser:inMyContactListOfType: table %@ not exists", tableName);
            return;
        }
        NSNumber *uniqueId = @([userId integerValue]);
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE unique_id = ?", tableName];
        FMResultSet *s = [db executeQuery:sql,uniqueId];
        [s next];
        result = ([s intForColumnIndex:0] > 0);
        [s close];
    }];
    return result;
}

#pragma mark - Private
- (BOOL)resetContactListTable:(SAMCContactListType)listType
{
    __block BOOL result = YES;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSArray *sqls;
        if (listType == SAMCContactListTypeCustomer) {
            sqls = @[@"DROP TABLE IF EXISTS contact_list_customer",
                     SAMC_CREATE_CONTACT_LIST_CUSTOMER_TABLE_SQL_2016082201];
        } else if (listType == SAMCContactListTypeServicer) {
            sqls = @[@"DROP TABLE IF EXISTS contact_list_servicer",
                     SAMC_CREATE_CONTACT_LIST_SERVICER_TABLE_SQL_2016082201];
        }
        for (NSString *sql in sqls) {
            if (![db executeUpdate:sql]) {
                DDLogError(@"error: execute sql %@ failed error %@",sql,[db lastError]);
                result = NO;
            }
        }
    }];
    return result;
}

@end
