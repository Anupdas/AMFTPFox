//
//  CWFTPUploadOperation.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFTPOperation.h"
#import "BRRequest.h"
#import "BRRequestUpload.h"
#import "BRRequestDownload.h"
#import "BRRequestListDirectory.h"

@interface CWFTPOperation ()<BRRequestDelegate>

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong, readwrite) BRRequest *request;

@property (nonatomic, strong) NSSet *runLoopModes;

@property (nonatomic, copy) CWFTPOperationProgressBlock progressBlock;
@property (nonatomic, copy) CWFTPOperationSuccessBlock successBlock;
@property (nonatomic, copy) CWFTPOperationFailureBlock failureBlock;



@end

@implementation CWFTPOperation

- (instancetype)initWithRequest:(BRRequest *)request{
    self = [super init];
    if (self) {
        self.request = request;
        self.request.delegate = self;
        
        self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    }return self;
}

- (void)start{
    [self.lock lock];
    if ([self isCancelled]) {
        [self.request cancelRequest];
    }else if([self isReady]){
//        [self performSelector:@selector(startOperation)
//                             onThread:[[self class] networkRequestThread]
//                           withObject:nil
//                        waitUntilDone:NO];
        [self.request start];
    }
    [self.lock unlock];
}

- (void)startOperation{
    if (![self isCancelled]) {
        [self.request start];
    }
}


- (void)cancel{
    [self.lock lock];
    if (![self isCancelled]) {
        [super cancel];
    
        [self performSelector:@selector(cancelRequest)
                             onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO];
    }
    [self.lock unlock];
}

- (BOOL)isAsynchronous{
    return YES;
}

#pragma mark - 

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"FoxFTP"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}


#pragma mark - Setters

- (void)setProgressBlock:(CWFTPOperationProgressBlock)progressBlock{
    _progressBlock = progressBlock;
}

- (void)setCompletionBlockWithSuccess:(CWFTPOperationSuccessBlock)successBlock
                              failure:(CWFTPOperationFailureBlock)failureBlock{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
}

#pragma mark - BRRequest Delegates

- (void)percentCompleted:(BRRequest *)request{
    if (self.progressBlock) {
        self.progressBlock(request.percentCompleted);
    }
}

- (void)requestCompleted:(BRRequest *)request{
    id responseObject = nil;
    if ([request isKindOfClass:[BRRequestListDirectory class]]) {
        responseObject = ((BRRequestListDirectory *)request).filesInfo;
    }else if([request isKindOfClass:[BRRequestDownload class]]){
        responseObject = ((BRRequestDownload *)request).receivedData;
    }
    
    if (self.successBlock) {
        self.successBlock(request,responseObject);
    }
}

- (void)requestFailed:(BRRequest *)request{
    if (self.failureBlock) {
        NSError *error = [NSError errorWithDomain:@"com.FTPFOX.Error"
                                             code:400
                                         userInfo:@{NSLocalizedDescriptionKey:@"Unable to complete the operation, please retry after sometime."}];
        self.failureBlock(request,error);
    }
}

- (BOOL)shouldOverwriteFileWithRequest:(BRRequest *)request{
    return YES;
}

@end
