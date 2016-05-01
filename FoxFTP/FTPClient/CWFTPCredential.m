//
//  CWFTPCredentials.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 01/05/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFTPCredential.h"

NSString *const kCWFTPCredentialsUsername = @"username";
NSString *const kCWFTPCredentialsPassword = @"password";
NSString *const kCWFTPCredentialsHost = @"host";
NSString *const kCWFTPCredentialsPort = @"port";


@interface CWFTPCredential ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation CWFTPCredential

@synthesize username = _username;
@synthesize password = _password;
@synthesize host = _host;
@synthesize port = _port;


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
        self.username = [self objectOrNilForKey:kCWFTPCredentialsUsername fromDictionary:dict];
        self.password = [self objectOrNilForKey:kCWFTPCredentialsPassword fromDictionary:dict];
        self.host = [self objectOrNilForKey:kCWFTPCredentialsHost fromDictionary:dict];
        self.port = [self objectOrNilForKey:kCWFTPCredentialsPort fromDictionary:dict];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.username forKey:kCWFTPCredentialsUsername];
    [mutableDict setValue:self.password forKey:kCWFTPCredentialsPassword];
    [mutableDict setValue:self.host forKey:kCWFTPCredentialsHost];
    [mutableDict setValue:self.port forKey:kCWFTPCredentialsPort];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description
{
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
    
    self.username = [aDecoder decodeObjectForKey:kCWFTPCredentialsUsername];
    self.password = [aDecoder decodeObjectForKey:kCWFTPCredentialsPassword];
    self.host = [aDecoder decodeObjectForKey:kCWFTPCredentialsHost];
    self.port = [aDecoder decodeObjectForKey:kCWFTPCredentialsPort];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_username forKey:kCWFTPCredentialsUsername];
    [aCoder encodeObject:_password forKey:kCWFTPCredentialsPassword];
    [aCoder encodeObject:_host forKey:kCWFTPCredentialsHost];
    [aCoder encodeObject:_port forKey:kCWFTPCredentialsPort];
}

- (id)copyWithZone:(NSZone *)zone
{
    CWFTPCredential *copy = [[CWFTPCredential alloc] init];
    
    if (copy) {
        
        copy.username = [self.username copyWithZone:zone];
        copy.password = [self.password copyWithZone:zone];
        copy.host = [self.host copyWithZone:zone];
        copy.port = [self.port copyWithZone:zone];
    }
    
    return copy;
}

@end
