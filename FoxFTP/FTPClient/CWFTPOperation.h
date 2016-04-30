//
//  CWFTPUploadOperation.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BRRequest;

typedef void(^CWFTPOperationProgressBlock)(float progress);
typedef void(^CWFTPOperationSuccessBlock)(BRRequest *request, id responseObject);
typedef void(^CWFTPOperationFailureBlock)(BRRequest *request, NSError *error);

@interface CWFTPOperation : NSOperation

@property (nonatomic, strong, readonly) BRRequest *request;

- (instancetype)initWithRequest:(BRRequest *)request;

/**
 *  Progress Block with progress,
 *
 *  @param progressBlock Progress Value from 0.0 to 1.0
 */
- (void)setProgressBlock:(CWFTPOperationProgressBlock)progressBlock;

/**
 *  Completion block
 *
 *  @param successBlock Request and response
 *  @param failureBlock Request and error
 */
- (void)setCompletionBlockWithSuccess:(CWFTPOperationSuccessBlock)successBlock
                              failure:(CWFTPOperationFailureBlock)failureBlock;

@end
