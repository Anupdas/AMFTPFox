//
//  CWDetailViewController.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 01/05/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CWFTPFile;
@interface CWDetailViewController : UIViewController

- (instancetype)initWithFile:(CWFTPFile *)file;

@end
