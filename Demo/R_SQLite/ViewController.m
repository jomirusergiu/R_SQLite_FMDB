//
//  ViewController.m
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

#import "ViewController.h"
#import "R_SQLite.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
