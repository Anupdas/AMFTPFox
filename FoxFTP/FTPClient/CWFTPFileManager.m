//
//  CWFTPFileManager.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 01/05/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFTPFileManager.h"
#import "NSArray+Additions.h"
#import "CWFTPFile.h"

NSString *const kFTPFileCacheKey = @"FTPFileCacheKey";

NSString *const CWFTPRootDirectory = @"/";

@interface CWFTPFileManager ()

@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSCache *fileCache;
@property (nonatomic, assign, readwrite) NSUInteger fileCount;

/**
 *  A temporary local file system path for file based activities
 */
@property (nonatomic, strong) NSString *localRootDirectoryPath;

@end

@implementation CWFTPFileManager

- (instancetype)initWithHost:(NSString *)host username:(NSString *)username{
    self = [super init];
    if (self) {
        _host = host;
        _username = username;
        _rootDirectory = CWFTPRootDirectory;
        _fileCache = [NSCache new];
    }return self;
}

+ (instancetype)sharedManager{
    static CWFTPFileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });return sharedManager;
}

#pragma mark - Getters

- (NSString *)localRootDirectoryPath{
    if (!_localRootDirectoryPath) {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSArray *pathComponents = @[cachesDirectory,self.host,self.username,self.rootDirectory];
        NSString *filePath = [pathComponents componentsJoinedByString:@"/"];
        _localRootDirectoryPath = filePath;
        
        [self createIntermediateDirectoriesIfNeededForPath:filePath];
    }return _localRootDirectoryPath;
}

- (NSArray *)files{
    return [self filesAtDirectory:nil];
}


#pragma mark - Setters

- (void)setRootDirectory:(NSString *)rootDirectory{
    if (![_rootDirectory isEqualToString:rootDirectory]) {
        _rootDirectory = rootDirectory;
        
        //Force reloading of local root directory based on new root directory
        _localRootDirectoryPath = nil;
    }
}


- (BOOL)writeImageData:(NSData *)data resourceName:(NSString *)resourceName{
    NSString *filePath = [self.localRootDirectoryPath stringByAppendingPathComponent:resourceName];
    [self createIntermediateDirectoriesIfNeededForPath:filePath];
    return [data writeToFile:filePath
                  atomically:YES];
}

#pragma mark - Public Methods

- (CWFTPFile *)fileForResourceName:(NSString *)resourceName{
    NSArray *files = [self.fileCache objectForKey:self.rootDirectory];
    return [files findFirstByAttribute:@"resourceName"
                             withValue:resourceName];
}

- (BOOL)fileExistsAtDirectory:(NSString *)resourceName{
    return [self fileForResourceName:resourceName]?YES:NO;
}

- (BOOL)localFileExistsAtPath:(NSString *)resourceName{
    NSString *filePath = [self.localRootDirectoryPath stringByAppendingPathComponent:resourceName];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (NSURL *)localFileURLForResourceName:(NSString *)resourceName{
    NSString *filePath = [self.localRootDirectoryPath stringByAppendingPathComponent:resourceName];
    return [NSURL fileURLWithPath:filePath];
}

- (NSArray *)filesAtDirectory:(NSString *)remoteDirectoryPath{
    return [self.fileCache objectForKey:remoteDirectoryPath?:self.rootDirectory];
}

- (NSArray *)saveFilesAtDirectory:(NSArray *)dictionaries{
    if (!dictionaries)  return nil;
    
    NSMutableArray *files = [CWFTPFile modelsFromDictionaries:dictionaries];
    if (files) {
        [self willChangeValueForKey:@"fileCount"];
        self.fileCount = files.count;
        [self.fileCache setObject:files
                           forKey:self.rootDirectory];
        [self didChangeValueForKey:@"fileCount"];
    }return files;
}

- (BOOL)addFile:(CWFTPFile *)file{
    if (!file || ![file isKindOfClass:[CWFTPFile class]]) {
        return NO;
    }
    
    if (![self fileExistsAtDirectory:file.resourceName]) {
        [self willChangeValueForKey:@"fileCount"];
        NSMutableArray *files = [self.fileCache objectForKey:self.rootDirectory];
        [files addObject:file];
        self.fileCount = files.count;
        [self didChangeValueForKey:@"fileCount"];
        return YES;
    }return NO;
}

- (NSString *)findUniqueFileName:(NSString *)resourceName{
    
    if (![self fileExistsAtDirectory:resourceName]) return resourceName;
    
    NSString *extension = [resourceName pathExtension];
    NSString *fileName = [resourceName stringByDeletingPathExtension];
    
    NSArray *files = [self filesAtDirectory:self.rootDirectory];
    
    //This is prone to race conditions, but for simple applications it is ok
    for (NSUInteger idx = 1;;idx++) {
        NSString *tempFileName = [NSString stringWithFormat:@"%@(%lu).%@",fileName,idx,extension];
        if (![files findFirstByAttribute:@"resourceName" withValue:tempFileName]) {
            return tempFileName;
        }
    } return nil;
}

- (BOOL)removeLocalFileAtPath:(NSString *)resourceName{
    id obj = [self fileForResourceName:resourceName];
    if (obj) {
        [self willChangeValueForKey:@"fileCount"];
        NSMutableArray *files = [self.fileCache objectForKey:self.rootDirectory];
        [files removeObject:obj];
        self.fileCount = files.count;
        [self didChangeValueForKey:@"fileCount"];
        return YES;
    } return NO;
}

- (NSString *)remotePathFromResourceName:(NSString *)resourceName{
    return [self.rootDirectory stringByAppendingPathComponent:resourceName];
}

#pragma mark - Utilities

- (BOOL)createIntermediateDirectoriesIfNeededForPath:(NSString *)filePath{
    NSString *directory = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directory]) {
        return [fileManager createDirectoryAtPath:directory
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:NULL];
    }return NO;
}


#pragma mark - 

- (void)clearCache{
    [self.fileCache removeAllObjects];
}


@end
