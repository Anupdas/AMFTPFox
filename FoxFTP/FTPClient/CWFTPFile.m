//
//  CWFTPFile.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFTPFile.h"

NSString *const kCWFTPFileKCFFTPResourceType = @"kCFFTPResourceType";
NSString *const kCWFTPFileKCFFTPResourceName = @"kCFFTPResourceName";
NSString *const kCWFTPFileKCFFTPResourceSize = @"kCFFTPResourceSize";
NSString *const kCWFTPFileKCFFTPResourceURL = @"kCFFTPResourceURL";
NSString *const kCWFTPFileKCFFTPResourceProgress = @"kCFFTPResourceProgress";


@interface CWFTPFile ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation CWFTPFile

+ (NSMutableArray *)modelsFromDictionaries:(NSArray *)dictionaries{
    NSMutableArray *files = [NSMutableArray new];
    for (NSDictionary *dict in dictionaries) {
        id file = [self modelObjectWithDictionary:dict];
        if (file) {
            [files addObject:file];
        }
    }return files;
}

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.resourceType = [[self objectOrNilForKey:kCWFTPFileKCFFTPResourceType fromDictionary:dict] integerValue];
        self.resourceName = [self objectOrNilForKey:kCWFTPFileKCFFTPResourceName fromDictionary:dict];
        self.resourceSize = [[self objectOrNilForKey:kCWFTPFileKCFFTPResourceSize fromDictionary:dict] doubleValue];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.resourceType] forKey:kCWFTPFileKCFFTPResourceType];
    [mutableDict setValue:self.resourceName forKey:kCWFTPFileKCFFTPResourceName];
    [mutableDict setValue:[NSNumber numberWithDouble:self.resourceSize] forKey:kCWFTPFileKCFFTPResourceSize];
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.resourceType = [aDecoder decodeDoubleForKey:kCWFTPFileKCFFTPResourceType];
    self.resourceName = [aDecoder decodeObjectForKey:kCWFTPFileKCFFTPResourceName];
    self.resourceSize = [aDecoder decodeInt64ForKey:kCWFTPFileKCFFTPResourceSize];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeDouble:_resourceType forKey:kCWFTPFileKCFFTPResourceType];
    [aCoder encodeObject:_resourceName forKey:kCWFTPFileKCFFTPResourceName];
    [aCoder encodeInt64:_resourceSize forKey:kCWFTPFileKCFFTPResourceSize];
}

- (id)copyWithZone:(NSZone *)zone
{
    CWFTPFile *copy = [[CWFTPFile alloc] init];
    
    if (copy) {
        copy.resourceType = self.resourceType;
        copy.resourceName = [self.resourceName copyWithZone:zone];
        copy.resourceSize = self.resourceSize;
    }
    
    return copy;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }else if([object isKindOfClass:[CWFTPFile class]]){
        return [self isEqualToFTPFile:object];
    }return NO;
}

/**
 *  Equality of two FTP File Objects. Resource file size and resource name
 *
 *  @param file Second Object
 *
 *  @return YES is same
 */
- (BOOL)isEqualToFTPFile:(CWFTPFile *)file{
    return self.resourceSize == file.resourceSize &&
            [self.resourceName isEqualToString:file.resourceName];
}
                                   

#pragma mark - KVO for progress

- (void)setProgress:(float)progress{
    [self willChangeValueForKey:@"progress"];
    _progress = progress;
    [self didChangeValueForKey:@"progress"];
}

- (BOOL)isDirectory{
    return self.resourceType == 4;
}

@end
