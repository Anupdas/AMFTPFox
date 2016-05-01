//
//  CWFTPClient.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWFTPCredential.h"
#import "CWFTPFileManager.h"
@class CWFTPFile;

extern NSString *const CWFTPRequestProgressChanged;
extern NSString *const CWFTPRequestSuccessful;
extern NSString *const CWFTPRequestFailure;

typedef void(^CWFTPCompletionBlock)(id response, NSError *error);
typedef void(^CWFTPProgressBlock)(float percentage);

@interface CWFTPClient : NSObject

@property (nonatomic, strong, readonly) CWFTPCredential *credential;

/**
 *  Observable Upload Count
 */
@property (nonatomic, assign, readonly) NSUInteger uploadCount;

/**
 *  Observable Upload Progress
 */
@property (nonatomic, assign, readonly) float uploadProgress;

@property (nonatomic, strong, readonly) CWFTPFileManager *fileManager;

/**
 *  Shared Instance of FTP Client
 *
 *  @return Instance of FTP Client
 */
+ (instancetype)sharedClient;

/**
 *  Update FTP Credentials. Clears all cached associated with a user on changing credential
 *
 *  @param credentials Credential Instance. Should have a valid host, username and password
 */
- (void)signInWithCredential:(CWFTPCredential *)credentials
                        save:(BOOL)shouldSave;

/**
 *  Removes saved credential if any and stops all ongoing requests
 */
- (void)logOutUser;


#pragma mark - Resources

/**
 *  All Upload Files In progress
 *
 *  @return CWFTPFile Instances
 */
- (NSArray *)allUploadFiles;

#pragma mark - API Calls


/**
 *  List directory contents at path. Only one list operation is possible at any time.
 *
 *  @param path    Path to remote directory to list.
 *  @param success Method called when process succeeds.
 *  @param failure Method called when process fails.
 */
- (void)listContentsAtPath:(NSString *)path
                  progress:(CWFTPProgressBlock)progressBlock
                completion:(CWFTPCompletionBlock)completionBlock;

/**
 *  Download a file asynchronously. Only one download is possible at any time. 
 *
 *  @param resourceName    Name of resource
 *  @param progressBlock   Progress Block with percentage
 *  @param completionBlock Completion Block with receiveData and error if any, either data or error
 */
- (void)downloadFile:(NSString *)resourceName
            progress:(CWFTPProgressBlock)progressBlock
          completion:(CWFTPCompletionBlock)completionBlock;

- (void)cancelDownloadRequest;

/**
 *  Create directory
 *
 *  @param directory       Directory path
 *  @param completionBlock Asynchronous completionBlock
 */
- (void)createDirectory:(NSString *)directory
             completion:(CWFTPCompletionBlock)completionBlock;

/**
 *  Upload file to specific directory on remote server. Multiple downloads are possible.
 *
 *  @param file Instance of file with fileURL and fileID
 */
- (void)uploadFile:(CWFTPFile *)file;

/**
 *  Cancel Ongoing upload operation
 *
 *  @param file CWFTPFile instance
 */
- (void)cancelUploadFile:(CWFTPFile *)file;

/**
 *  Delete a file at specified remote path.
 *
 *  @param remotePath The path to the remote resource to delete.
 *
 */
- (void)deleteFileAtPath:(NSString *)remotePath;


@end
