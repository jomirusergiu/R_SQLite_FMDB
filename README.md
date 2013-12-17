R_SQLite
=================

R_SQLite is a small class using FMDB SQLite wrapper for managing databases.

Usage
-------------
```Objective-C
    //Alloc R_SQLite
    R_SQLite *r_SQLite = [R_SQLite new];
    
    //Create new database at path
    [r_SQLite createDBAtPath:@"/tmp/tmp.db"];
    
    //Create table with structure
    [r_SQLite createTable:@"test" withStructure:@"a text, b text, c integer, d double, e double"];
    
    //Update table
    [r_SQLite update];
    
    //Get results
    [r_SQLite getResultSetFromTableAndRows];
    
    //Close database
    [r_SQLite closeAndGetDatabaseVersion];
    
    //Dealloc
    r_SQLite = nil;
```

License
--------

This code is under the BSD license.
