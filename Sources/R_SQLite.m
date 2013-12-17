//
//  R_SQLite.m
//  R_SQLite
//
//  Created by RocKK on 11/22/13.
//  Copyright (c) 2013 RocKK.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms are permitted
//  provided that the above copyright notice and this paragraph are
//  duplicated in all such forms and that any documentation,
//  advertising materials, and other materials related to such
//  distribution and use acknowledge that the software was developed
//  by the RocKK.  The name of the
//  RocKK may not be used to endorse or promote products derived
//  from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED ''AS IS'' AND WITHOUT ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

#import "R_SQLite.h"
#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

@interface R_SQLite ()
@end

FMDatabase *db;

@implementation R_SQLite

- (void)createDBAtPath:(NSString *)dbPath{
    NSLog(@"Create Database at path %@", dbPath);
    
    //Delete old DataBase at path if it exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:dbPath error:nil];
    db = [FMDatabase databaseWithPath:dbPath];
    
    //Check isSQLiteThreadSafe
    NSLog(@"Is SQLite compiled with it's thread safe options turned on? %@!", [FMDatabase isSQLiteThreadSafe] ? @"Yes" : @"No");
    
    // Un-opened database check.
    FMDBQuickCheck([db executeQuery:@"select * from table"] == nil);
    NSLog(@"Error code: %d, Error message: %@", [db lastErrorCode], [db lastErrorMessage]);
    
    //Try if database opened
    if (![db open])
        NSLog(@"Could not open db.");
    else
        NSLog(@"Database is good to go.");
    
    //Set And Check Properties
    [self setAndCheckProperties];
    NSLog(@"\n");
}

- (void)setAndCheckProperties{
    //Set Cache on, kind of experimentalish.
    [db setShouldCacheStatements:YES];
    
    // Empty strings should still return a value.
    FMDBQuickCheck(([db boolForQuery:@"SELECT ? not null", @""]));
    
    // Same with empty bits o' mutable data
    FMDBQuickCheck(([db boolForQuery:@"SELECT ? not null", [NSMutableData data]]));
    
    // Same with empty bits o' data
    FMDBQuickCheck(([db boolForQuery:@"SELECT ? not null", [NSData data]]));
    
    // How do we do pragmas?  Like so:
    FMResultSet *ps = [db executeQuery:@"PRAGMA journal_mode=delete"];
    FMDBQuickCheck(![db hadError]);
    FMDBQuickCheck(ps);
    FMDBQuickCheck([ps next]);
    [ps close];
    
    // Oh, but some pragmas require updates?
    [db executeUpdate:@"PRAGMA page_size=2048"];
    FMDBQuickCheck(![db hadError]);
    
    // What about a vacuum?
    [db executeUpdate:@"vacuum"];
    FMDBQuickCheck(![db hadError]);
}

- (void)executeBadStatement{
    //For the sake of testing, to see what happens if we do something wrong;
    NSLog(@"Execute Bad Statement");
    
    // Create a bad statement, just to test the error code.
    [db executeUpdate:@"Some Wrong Syntax String"];
    
    // Check if db had error
    FMDBQuickCheck([db hadError]);
    if ([db hadError]) {
        NSLog(@"Error code %d: Error Message%@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    //Check if db had update with some error syntax string
    NSError *err = 0x00;
    FMDBQuickCheck(![db update:@"Some Wrong Syntax String" withErrorAndBindings:&err]);
    FMDBQuickCheck(err != nil);
    FMDBQuickCheck([err code] == SQLITE_ERROR);
    NSLog(@"Full Error Info: '%@'", err);
    NSLog(@"\n");
}

- (void)createTable:(NSString*)tableName withStructure:(NSString*)fieldsAndTypes{
    NSLog(@"Created table \"test\"");
    
    // CreateTable
    [db executeUpdate:[NSString stringWithFormat:@"create table %@ (%@)", tableName, fieldsAndTypes]];
    NSLog(@"\n");
}

- (void)update{
    NSLog(@"Update Database");
    
    // Begin Update Transaction
    [db beginTransaction];
    int i = 0;
    while (i++ < 20) {
        [db executeUpdate:@"insert into test (a, b, c, d, e) values (?, ?, ?, ?, ?)" ,
         @"stringKeyword",
         [NSString stringWithFormat:@"index%d",i],
         [NSNumber numberWithInt:i],
         [NSDate date],
         [NSNumber numberWithFloat:2.2f]];
    }
    
    // Commit
    [db commit];
    NSLog(@"Added values to \"test\"");
    NSLog(@"\n");
}

- (void)getResultSetFromTableAndRows{
    NSLog(@"Get Results");
    
    // Create Result Set
    FMResultSet *rs = [db executeQuery:@"select rowid,* from test where a = ?", @"stringKeyword"];
    while ([rs next]) {
        
        // Print out what we've got in a number of formats.
        NSLog(@"%@ %@ %@ %@ %@ %f %f",
              [rs stringForColumn:@"rowid"],
              [rs stringForColumn:@"a"],
              [rs stringForColumn:@"b"],
              [rs stringForColumn:@"c"],
              [rs dateForColumn:@"d"],
              [rs doubleForColumn:@"d"],
              [rs doubleForColumn:@"e"]);
    }
    
    // Close result set
    [rs close];
    NSLog(@"\n");
}

- (void)closeAndGetDatabaseVersion{
    NSLog(@"Closing Database");
    
    //Close Database
    [db close];
    NSLog(@"That was version %@ of SQLite", [FMDatabase sqliteLibVersion]);
}

@end
