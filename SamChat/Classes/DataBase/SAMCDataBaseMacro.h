//
//  SAMCDataBaseMacro.h
//  SamChat
//
//  Created by HJ on 8/31/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#ifndef SAMCDataBaseMacro_h
#define SAMCDataBaseMacro_h

#define SAMC_CREATE_FOLLOW_LIST_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS follow_list(serial INTEGER PRIMARY KEY AUTOINCREMENT, \
unique_id INTEGER UNIQUE, username TEXT NOT NULL, avatar TEXT, block_tag INTEGER, \
favourite_tag INTEGER, sp_service_category TEXT, last_message_content TEXT)"

#define SAMC_CREATE_CONTACT_LIST_CUSTOMER_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS contact_list_customer(\
serial INTEGER PRIMARY KEY AUTOINCREMENT, unique_id INTEGER UNIQUE)"

#define SAMC_CREATE_CONTACT_LIST_SERVICER_TABLE_SQL_2016082201 @"CREATE TABLE IF NOT EXISTS contact_list_servicer(\
serial INTEGER PRIMARY KEY AUTOINCREMENT, unique_id INTEGER UNIQUE)"

#endif /* SAMCDataBaseMacro_h */
