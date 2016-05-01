//
//  NSArray+Additions.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 01/05/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (id)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue{
    id firstObject = nil;
    NSUInteger count = self.count;
    for (int i =0; i<count;i++) {
        id object = self[i];
        id value = [object valueForKey:attribute];
        if ([value isEqual:searchValue]){
            firstObject = object;
            break;
        }
    }return firstObject;
}

/*
 A simple fast enumeration + mutable array is the fastest way to filter values,
 predicates are in general 2 to 3 times slower but has good syntax and readability
 */
- (id)findByAttribute:(NSString *)attribute withValue:(id)searchValue{
    NSMutableArray *values = [NSMutableArray new];
    for (id object in self) {
        id value = [object valueForKey:attribute];
        if ([value isEqual:searchValue]) [values addObject:object];
    }return values;
}


@end
