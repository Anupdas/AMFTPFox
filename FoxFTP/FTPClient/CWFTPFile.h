//
//  CWFTPFile.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CWFTPFileTypeImage = 0,
    CWFTPFileTypeVideo = 1,
    CWFTPFileTypeDirectory = 4
}CWFTPFileType;

@interface CWFTPFile : NSObject<NSCoding>

/**
 *  Uploading file URL
 */
@property (nonatomic, copy) NSURL *fileURL;

/**
 *  Unique identifier for file
 */
@property (nonatomic, assign) NSUInteger fileID;

/**
 *  Type of resource image or video
 */
@property (nonatomic, assign) CWFTPFileType resourceType;
/**
 *  ResourceName with respect to root
 */
@property (nonatomic, strong) NSString *resourceName;

/**
 *  Resource size
 */
@property (nonatomic, assign) int64_t resourceSize;

/**
 *  Resource Data for Upload
 */
@property (nonatomic, strong) NSData *resourceData;

/**
 *  Upload Progress
 */
@property (nonatomic, assign) float progress;

- (BOOL)isDirectory;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

+ (NSMutableArray *)modelsFromDictionaries:(NSArray *)dictionaries;


@end
