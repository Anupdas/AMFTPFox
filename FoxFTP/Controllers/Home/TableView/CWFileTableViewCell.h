//
//  CWFileTableViewCell.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CWFTPFile;

@interface CWFileTableViewCell : UITableViewCell

@property (nonatomic, strong) CWFTPFile *file;

@end
