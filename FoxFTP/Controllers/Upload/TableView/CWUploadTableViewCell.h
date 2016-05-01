//
//  CWUploadTableViewCell.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CWFTPFile;
@interface CWUploadTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) CWFTPFile *file;

- (void)setProgress:(CGFloat)progress;

@end
