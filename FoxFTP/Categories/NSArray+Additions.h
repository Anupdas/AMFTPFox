//
//  NSArray+Additions.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 01/05/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

//Find First Object with Value for attribute
- (id)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue;

//Find All Objects with Value for attribute
- (id)findByAttribute:(NSString *)attribute withValue:(id)searchValue;

@end
