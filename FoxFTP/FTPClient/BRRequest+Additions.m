//
//  BRRequest+Additions.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "BRRequest+Additions.h"
#import "CWFTPFile.h"

@implementation BRRequest (Additions)

- (NSInteger)tag{
    return [self.userDictionary[@"RequestTag"] integerValue];
}

- (void)setTag:(NSInteger)tag{
    self.userDictionary[@"RequestTag"] = @(tag);
}

- (BRRequestTypes)requestType{
    return (BRRequestTypes)[self.userDictionary[@"RequestType"] integerValue];
}

- (void)setRequestType:(BRRequestTypes)requestType{
    self.userDictionary[@"RequestType"] = @(requestType);
}

- (CWFTPFile *)ftpFile{
    return self.userDictionary[@"CWFTPFile"];
}

- (void)setFtpFile:(CWFTPFile *)ftpFile{
    if (ftpFile) {
        self.userDictionary[@"CWFTPFile"] = ftpFile;
    }else{
        [self.userDictionary removeObjectForKey:@"CWFTPFile"];
    }
    
}
@end
