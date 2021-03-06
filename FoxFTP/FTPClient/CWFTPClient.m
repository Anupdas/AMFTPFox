//
//  CWFTPClient.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFTPClient.h"
#import "BRRequestListDirectory.h"
#import "BRRequestDownload.h"
#import "BRRequestUpload.h"
#import "BRRequestCreateDirectory.h"
#import "BRRequestDelete.h"
#import "BRRequest+_UserData.h"
#import "BRRequest+Additions.h"
#import "CWFTPOperation.h"
#import "CWFTPFile.h"

NSString *const kCWFTPClientSavedUser = @"FTPClientSavedUser";

@interface CWFTPClient ()<BRRequestDelegate>

@property (nonatomic, strong, readwrite) CWFTPCredential *credential;
@property (nonatomic, assign) BOOL shouldSaveCredential;

@property (nonatomic, copy) CWFTPCompletionBlock signInCompletionBlock;

@property (nonatomic, copy) CWFTPProgressBlock listProgressBlock;
@property (nonatomic, copy) CWFTPCompletionBlock listCompletionBlock;

@property (nonatomic, copy) CWFTPProgressBlock downloadProgressBlock;
@property (nonatomic, copy) CWFTPCompletionBlock downloadCompletionBlock;
@property (nonatomic, strong) NSMutableData *downloadData;

@property (nonatomic, assign, readwrite) NSUInteger uploadCount;
@property (nonatomic, assign, readwrite) float uploadProgress;

@property (nonatomic, copy) CWFTPCompletionBlock deleteCompletionBlock;

@property (nonatomic, strong) NSMutableArray *ftpRequests;
@property (nonatomic, strong) NSMutableArray *uploadFiles;

@end

@implementation CWFTPClient

+ (instancetype)sharedClient{
    static CWFTPClient *__sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedClient = [[self alloc] init];
    }); return __sharedClient;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _ftpRequests = [NSMutableArray new];
        _uploadFiles = [NSMutableArray new];
        
        if (self.credential) {
            _fileManager = [[CWFTPFileManager alloc] initWithHost:self.credential.host
                                                         username:self.credential.username];
        }
    }return self;
}

#pragma mark - Credential Management

- (CWFTPCredential *)credential{
    if (!_credential) {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCWFTPClientSavedUser];
        if (data) {
            _credential = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }return _credential;
}

- (NSString *)host{
    return self.credential.host;
}

- (NSString *)username{
    return self.credential.username;
}

- (NSString *)password{
    return self.credential.password;
}

- (void)signInWithCredential:(CWFTPCredential *)credential
                    save:(BOOL)shouldSave{

    _credential = credential;
    _fileManager = [[CWFTPFileManager alloc] initWithHost:credential.host
                                                 username:credential.username];
    _shouldSaveCredential = shouldSave;
}

- (void)logOutUser{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCWFTPClientSavedUser];
    _credential = nil;
    [self cancelAllOperations];
}

#pragma mark - Upload Queue

- (CWFTPFile *)fileForRequest:(BRRequest *)request{
    for (CWFTPFile *file in self.uploadFiles) {
        if (file.fileID == request.tag) {
            return file;
        }
    }return nil;
}

- (NSUInteger)uploadCount{
    return self.uploadFiles.count;
}

- (float)uploadProgress{
    return [[self.uploadFiles valueForKeyPath:@"@avg.progress"] floatValue];
}


- (void)addFile:(CWFTPFile *)file{
    [self willChangeValueForKey:@"uploadCount"];
    [self.uploadFiles addObject:file];
    self.uploadCount = self.uploadFiles.count;
    [self didChangeValueForKey:@"uploadCount"];
}

- (void)removeFile:(CWFTPFile *)file{
    [self willChangeValueForKey:@"uploadCount"];
    [self.uploadFiles removeObject:file];
    self.uploadCount = self.uploadFiles.count;
    [self didChangeValueForKey:@"uploadCount"];
}

#pragma mark - Files

- (NSArray *)allUploadFiles{
    return self.uploadFiles;
}

- (NSArray *)currentDirectoryFiles{
    return [self.fileManager filesAtDirectory:nil];
}

#pragma mark - Misc

- (void)startRequest:(BRRequest *)request{
    [self.ftpRequests addObject:request];
    [request start];
}

- (void)cancelRequest:(BRRequest *)request{
    [self.ftpRequests removeObject:request];
    [request cancelRequestWithFlag];
    
    if (request.ftpFile) {
        [self removeFile:request.ftpFile];
    }
}

- (void)finishRequest:(BRRequest *)request{
    if (request.ftpFile) {
        [self removeFile:request.ftpFile];
    }
    [self.ftpRequests removeObject:request];
    
}

#pragma mark - API Calls

- (void)listContentsAtPath:(NSString *)path
                  progress:(CWFTPProgressBlock)progressBlock
                completion:(CWFTPCompletionBlock)completionBlock{
    
    self.listProgressBlock = progressBlock;
    self.listCompletionBlock = completionBlock;
    
    BRRequest *request = [[BRRequestListDirectory alloc] initWithDelegate:self];
    request.hostname = self.host;
    request.path = self.fileManager.rootDirectory;
    request.username = self.username;
    request.password = self.password;
    request.tag = 0;
    request.requestType = kBRListDirectoryRequest;
    
    [self startRequest:request];
}

- (void)createDirectory:(NSString *)directory
             completion:(__autoreleasing CWFTPCompletionBlock)completionBlock
{
    BRRequestCreateDirectory *request = [[BRRequestCreateDirectory alloc] initWithDelegate:self];
    request.hostname = self.host;
    request.path = [self.fileManager.rootDirectory stringByAppendingPathComponent:directory];
    request.username = self.username;
    request.password = self.password;
    request.requestType = kBRCreateDirectoryRequest;
    
    [self startRequest:request];
}

- (void)downloadFile:(NSString *)resourceName
            progress:(CWFTPProgressBlock)progressBlock
          completion:(CWFTPCompletionBlock)completionBlock{
    
    self.downloadData = [NSMutableData new];
    BRRequestDownload *request = [[BRRequestDownload alloc] initWithDelegate:self];
    request.hostname = self.host;
    request.path = [self.fileManager.rootDirectory stringByAppendingPathComponent:resourceName];
    request.username = self.username;
    request.password = self.password;
    request.tag = 0;
    request.requestType = kBRDownloadRequest;
    
    //This is required to write the received data to local file system
    request.localFilepath = resourceName;
    
    self.downloadCompletionBlock = completionBlock;
    self.downloadProgressBlock = progressBlock;
    
    [self startRequest:request];
    
}

- (void)uploadFile:(CWFTPFile *)file{
    
    BRRequestUpload *request = [[BRRequestUpload alloc] initWithDelegate:self];
    request.hostname = self.host;
    request.path = [self.fileManager.rootDirectory stringByAppendingPathComponent:file.resourceName];
    request.username = self.username;
    request.password = self.password;
    request.requestType = kBRUploadRequest;
    
    //FTP file should be set for upload to work, ftp file should have a non-nil resourceData
    request.ftpFile = file;
    request.tag = file.fileID;
    
    //This will prevent unnecessary download of this file again
    [self.fileManager writeImageData:file.resourceData
                        resourceName:file.resourceName];
    
    [self addFile:file];
    
    [self startRequest:request];
}

- (void)cancelUploadFile:(CWFTPFile *)file{
    for (BRRequest *request in self.ftpRequests) {
        if (request.ftpFile == file) {
            request.cancelDoesNotCallDelegate = YES;
            [self cancelRequest:request];
            break;
        }
    }
}

- (void)cancelDownloadRequest{
    for (BRRequest *request in self.ftpRequests) {
        if (request.requestType == kBRDownloadRequest) {
            request.cancelDoesNotCallDelegate = YES;
            [self cancelRequest:request];
            break;
        }
    }
}

- (void)deleteFile:(CWFTPFile *)file
        completion:(CWFTPCompletionBlock)block{
    self.deleteCompletionBlock = block;
    //Delete Request blocks the main thread hence a concurrent queue is used to free UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BRRequestDelete *request = [[BRRequestDelete alloc] initWithDelegate:self];
        request.hostname = self.host;
        request.path = [self.fileManager.rootDirectory stringByAppendingPathComponent:file.resourceName];
        request.username = self.username;
        request.password = self.password;
        request.tag = 0;
        request.requestType = kBRDeleteRequest;
        request.ftpFile = file;
        
        [request start];
    });
}

#pragma mark - Request Delegates

- (void)postData:(NSDictionary *)info forEvent:(NSString *)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:info];
}

- (void)percentCompleted:(BRRequest *)request{
    switch (request.requestType) {
        case kBRListDirectoryRequest:{
            
            if (self.listProgressBlock) {
                self.listProgressBlock(request.percentCompleted);
            }
            break;
        }
        case kBRUploadRequest:{
            [self willChangeValueForKey:@"uploadProgress"];
            request.ftpFile.progress = request.percentCompleted;
            [self didChangeValueForKey:@"uploadProgress"];
            break;
        }
        case kBRDownloadRequest:{
            if (self.downloadProgressBlock) {
                self.downloadProgressBlock(request.percentCompleted);
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)requestCompleted:(BRRequest *)request{
    switch (request.requestType) {
        case kBRListDirectoryRequest:{
            
            //Save Credential on successful completion of file listing
            if (self.shouldSaveCredential) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.credential];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCWFTPClientSavedUser];
            }
            
            BRRequestListDirectory*listDirectory = (BRRequestListDirectory *)request;
            NSArray *files =[self.fileManager saveFilesAtDirectory:listDirectory.filesInfo];
            
            if (self.listCompletionBlock) {
                self.listCompletionBlock(files,nil);
            }
            break;
        }
        case kBRUploadRequest:{
            [self.fileManager addFile:request.ftpFile];
            request.ftpFile.resourceData = nil;
        }
        case kBRDownloadRequest:{
            BRRequestDownload *downloadRequest = (BRRequestDownload *)request;
            //Write downloaded data to local file system
            [self.fileManager writeImageData:self.downloadData
                                resourceName:downloadRequest.localFilepath];
            
            if (self.downloadCompletionBlock) {
                self.downloadCompletionBlock(self.downloadData, nil);
            }
            
            self.downloadData = nil;
            break;
        }
        case kBRDeleteRequest:{
            [self.fileManager removeLocalFileAtPath:request.ftpFile.resourceName];
            //ftp file is cleared so that upload files are not affected
            request.ftpFile = nil;
            if (self.deleteCompletionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.deleteCompletionBlock(request.path,nil);
                });
            }
            break;
        }
        default:
            break;
    }
    
    [self finishRequest:request];
}

- (void)requestFailed:(BRRequest *)request{
    switch (request.requestType) {
        case kBRListDirectoryRequest:{
            
            //Assuming credentials are wrong, tightly coupled with logic move to somewhere else
            _credential = nil;
            
            if (self.listCompletionBlock) {
                 NSError *error = [NSError errorWithDomain:@"com.FTPFOX.Error"
                                                      code:400
                                                  userInfo:@{NSLocalizedDescriptionKey:@"Unable to fetch directory contents. Please check the internet connection and retry."}];
                self.listCompletionBlock(nil,error);
            }
            
            break;
        }
        case kBRDownloadRequest:{
            if (self.downloadCompletionBlock) {
                NSError *error = [NSError errorWithDomain:@"com.FTPFOX.Error"
                                                     code:400
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Unable to download file. Please check the internet connection and retry."}];
                self.downloadCompletionBlock(nil,error);
            }break;
        }
        case kBRDeleteRequest:{
            request.ftpFile = nil;
            if (self.deleteCompletionBlock) {
                NSError *error = [NSError errorWithDomain:@"com.FTPFOX.Error"
                                                     code:400
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Unable to delete file. Please check the internet connection and retry."}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.deleteCompletionBlock(nil,error);
                });
            }
            break;
        }
        default:
            break;
    }
    [self finishRequest:request];
}

#pragma mark - Optional for Download and Upload

/* Append data and give back the data through block*/
- (void)requestDataAvailable:(BRRequestDownload *)request{
    [_downloadData appendData:request.receivedData];
}

/*This is for calculating the progress percentage of upload request*/
- (long)requestDataSendSize:(BRRequestUpload *)request{
    return request.ftpFile.resourceData.length;
}

/*The data to be uploaded to remote*/
- (NSData *)requestDataToSend:(BRRequestUpload *)request{
    NSData *temp = request.ftpFile.resourceData;
    request.ftpFile.resourceData = nil;
    return temp;
}

/*Only Upload request should send overwrite as YES*/
- (BOOL)shouldOverwriteFileWithRequest:(BRRequest *)request{
    return request.requestType == kBRUploadRequest;
}

#pragma mark - 

- (void)cancelAllOperations{
    for (BRRequest *request in self.ftpRequests) {
        [self cancelRequest:request];
    }
}

@end
