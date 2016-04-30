//
//  CWFTPClient.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CWFTPFile;

extern NSString *const CWFTPRequestProgressChanged;
extern NSString *const CWFTPRequestSuccessful;
extern NSString *const CWFTPRequestFailure;

typedef void(^CWFTPCompletionBlock)(id response, NSError *error);
typedef void(^CWFTPProgressBlock)(float percentage);

@interface CWFTPClient : NSObject

@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, assign) NSUInteger uploadCount;
@property (nonatomic, assign) float uploadProgress;

/**
 *  Shared Instance of FTP Client
 *
 *  @return Instance of FTP Client
 */
+ (instancetype)sharedClient;

#pragma mark - Operations

/**
 *  Flag to denote if upload is in progress
 */
@property (nonatomic, assign, getter=isUploading) BOOL uploading;

/**
 *  Maximum concurrent upload operations
 */
@property (nonatomic, assign) NSUInteger maxConcurrentUploads;

/**
 *  Current Upload Task Count
 *
 *  @return Task Count
 */
- (NSUInteger)ongoingUploadTasks;

/**
 *  Maximum concurrent download operations
 */
@property (nonatomic, assign) NSUInteger maxConcurrentDownloads;

/**
 *  Cancel On going operations
 */
- (void)cancelAllOperations;

#pragma mark - API Calls

/**
 *  List directory contents at path.
 *
 *  @param path    Path to remote directory to list.
 *  @param success Method called when process succeeds.
 *  @param failure Method called when process fails.
 */
- (void)listContentsAtPath:(NSString *)path
                  progress:(CWFTPProgressBlock)progressBlock
                completion:(CWFTPCompletionBlock)completionBlock;

/**
 *  Download a file asynchronously
 *
 *  @param remotePath Full path of remote file to download.
 *  @param localPath  Local path to download file to.
 */
- (void)downloadFile:(NSString *)remotePath
              toPath:(NSString *)localPath;

/**
 *  Upload file to specific directory on remote server.
 *
 *  @param file Instance of file with fileURL and fileID
 */
- (void)uploadFile:(CWFTPFile *)file;

/**
 *  Delete a file at specified remote path.
 *
 *  @param remotePath The path to the remote resource to delete.
 *
 *  @return YES on success. NO on failure.
 */
- (BOOL)deleteFileAtPath:(NSString *)remotePath;


@end
