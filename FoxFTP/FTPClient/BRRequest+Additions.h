//
//  BRRequest+Additions.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "BRRequest.h"

@class CWFTPFile;

@interface BRRequest (Additions)

@property NSInteger tag;
@property BRRequestTypes requestType;
@property CWFTPFile *ftpFile;

@end
