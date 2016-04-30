//
//  CWFTPClient.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFTPClient.h"
#import "BRRequestListDirectory.h"
#import "BRRequest+_UserData.h"
#import "BRRequest+Additions.h"
#import "CWFTPOperation.h"
#import "CWFTPFile.h"

NSUInteger const kListContentsTag = 1;
NSUInteger const kDownloadTag = 2;
NSUInteger const kUploadTag = 3;

NSString *const CWFTPRequestProgressChanged = @"CWFTPRequestProgressChanged";
NSString *const CWFTPRequestSuccessful = @"CWFTPRequestSuccessful";
NSString *const CWFTPRequestFailure = @"CWFTPRequestFailure";

@interface CWFTPClient ()<BRRequestDelegate>

@property (nonatomic, copy) CWFTPProgressBlock listProgressBlock;
@property (nonatomic, copy) CWFTPCompletionBlock listCompletionBlock;

@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

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
        _maxConcurrentUploads = 2;
        _maxConcurrentDownloads = 3;
    }return self;
}

#pragma mark - Upload Queue

- (NSOperationQueue *)uploadQueue{
    if (!_uploadQueue) {
        _uploadQueue = [NSOperationQueue new];
        _uploadQueue.name = @"com.FTPFox.UploadQueue";
        _uploadQueue.maxConcurrentOperationCount = self.maxConcurrentUploads;
    }return _uploadQueue;
}

- (void)setMaxConcurrentUploads:(NSUInteger)maxConcurrentUploads{
    _maxConcurrentUploads = maxConcurrentUploads;
    self.uploadQueue.maxConcurrentOperationCount = maxConcurrentUploads;
}

- (CWFTPFile *)fileForRequest:(BRRequest *)request{
    for (CWFTPFile *file in self.uploadFiles) {
        if (file.fileID == request.tag) {
            return file;
        }
    }
}

- (NSUInteger)uploadCount{
    return self.uploadFiles.count;
}

- (float)uploadProgress{
    float total = [[self.uploadFiles valueForKeyPath:@"@avg.progress"] floatValue];
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

#pragma mark - Download Queue

- (NSOperationQueue *)downloadQueue{
    if (!_downloadQueue) {
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.name = @"com.FTPFox.DownloadQueue";
        _downloadQueue.maxConcurrentOperationCount = self.maxConcurrentDownloads;
    }return _downloadQueue;
}

- (void)setMaxConcurrentDownloads:(NSUInteger)maxConcurrentDownloads{
    _maxConcurrentDownloads = maxConcurrentDownloads;
    self.downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

#pragma mark - API Calls

- (void)listContentsAtPath:(NSString *)path
                  progress:(CWFTPProgressBlock)progressBlock
                completion:(CWFTPCompletionBlock)completionBlock{
    
    _listProgressBlock = progressBlock;
    _listCompletionBlock = completionBlock;
    
    BRRequest *request = [[BRRequestListDirectory alloc] initWithDelegate:self];
    request.hostname = self.host;
    request.path = @"/";
    request.username = self.username;
    request.password = self.password;
    request.tag = kListContentsTag;
    request.requestType = kListContentsTag;
    
    [request start];
}

- (void)uploadFile:(CWFTPFile *)file{
    
    BRRequestUpload *request = [[BRRequestUpload alloc] initWithDelegate:self];
    request.hostname = self.host;
    request.username = self.username;
    request.password = self.password;
    request.tag = kListContentsTag;
    request.requestType = kUploadTag;
    
    request.tag = file.fileID;
    request.localFilePath = file.fileURL.absoluteString;
    request.fullRemotePath = [@"/" stringByAppendingPathComponent:file.resourceName];
    
    [self addFile:file];
    
    [request start];
}

#pragma mark - Request Delegates

- (void)postData:(NSDictionary *)info forRequestType:(BRRequestTypes)requestType{
    NSString *notificationName = ;
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
        case kBRUploadRequest{
            request.ftpFile.progress = request.percentCompleted;
            break;
        }
        default:
            break;
    }
    
    NSDictionary *info = @{@"fileID":@(request.tag),
                           @"requestType":@(request.requestType),
                           @"progress":@(request.percentCompleted)};
    [self postData:info forRequestType:request.requestType];
}

- (void)requestCompleted:(BRRequest *)request{
    switch (request.requestType) {
        case kBRListDirectoryRequest:{
            if (self.listCompletionBlock) {
                BRRequestListDirectory*listDirectory = (BRRequestListDirectory *)request;
                self.listCompletionBlock(listDirectory.filesInfo,nil);
            }
            break;
        }
        case kBRUploadRequest:{
            [self removeFile:request.ftpFile];
            break;
        }
            
        default:
            break;
    }
}

- (void)requestFailed:(BRRequest *)request{
    switch (request.requestType) {
        case kBRListDirectoryRequest:{
           
            if (self.listCompletionBlock) {
                 NSError *error = [NSError errorWithDomain:@"com.FTPFOX.Error"
                                                      code:400
                                                  userInfo:@{NSLocalizedDescriptionKey:@"Unable to fetch directory contents. Please retry later"}];
                self.listCompletionBlock(nil,error);
            }
            
            break;
        }
        case kBRUploadRequest:{
            [self removeFile:request.ftpFile];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - 

- (void)cancelAllOperations{
    [self.uploadQueue cancelAllOperations];
    [self.downloadQueue cancelAllOperations];
}

@end
