//
//  CWFTPFileManager.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 01/05/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CWFTPFile;

@interface CWFTPFileManager : NSObject

/**
 *  Current Working Directory w.r.t remote directory on local file system.
 */
@property (nonatomic, strong) NSString *rootDirectory;

/**
 *  Files of current working directory
 */
@property (nonatomic, strong, readonly) NSArray *files;

/**
 *  Observable File Count
 */
@property (nonatomic, assign, readonly) NSUInteger fileCount;


/**
 *  Default Initializer for FileManager
 *
 *  @param host     Host Name
 *  @param username Username
 *
 *  @return Instance of FileManager;
 */
- (instancetype)initWithHost:(NSString *)host
                    username:(NSString *)username;

/**
 *  Remote Files
 *
 *  @return NSArray of CWFTPFile instances
 */
- (NSArray *)filesAtDirectory:(NSString *)remoteDirectoryPath;

/**
 *  Save an array of NSDictionary Items
 *
 *  @param dictinaries NSDictionary Array
 *
 *  @return YES is success
 */
- (NSArray *)saveFilesAtDirectory:(NSArray *)dictionaries;

/**
 *  Add File to current working directory
 *
 *  @param file FTPFile Instance
 *
 *  @return YES if success
 */
- (BOOL)addFile:(CWFTPFile *)file;

/**
 *  Check if a remote file exists at path
 *
 *  @param remotePath Name of resource. If only file name is provided
 *
 *  @return YES is file exists
 */
- (BOOL)fileExistsAtDirectory:(NSString *)resourceName;

/**
 *  Checks if a local copy of resource exists at file system
 *
 *  @param resourceName Name of resource
 *
 *  @return YES if file exists
 */
- (BOOL)localFileExistsAtPath:(NSString *)resourceName;

/**
 *  Absolute file URL for resource
 *
 *  @param resourceName Name of resource
 *
 *  @return NSURL Instance
 */
- (NSURL *)localFileURLForResourceName:(NSString *)resourceName;

/**
 *  Find Unique file name
 *
 *  @param resourceName Name of resource
 *
 *  @return Unique name for given resource
 */
- (NSString *)findUniqueFileName:(NSString *)resourceName;

/**
 *  Write Image data.
 *
 *  @param data NSData
 *  @param resourceName Name of resource
 *
 *  @return YES if successfull written
 */
- (BOOL)writeImageData:(NSData *)data
          resourceName:(NSString *)resourceName;

/**
 *  Find the full remote path
 *
 *  @param resourceName Name of the resource
 *
 *  @return Full path of resource
 */
- (NSString *)remotePathFromResourceName:(NSString *)resourceName;

/**
 *  Clear Cache
 */
- (void)clearCache;

@end
