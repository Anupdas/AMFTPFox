//
//  CWFileTableViewCell.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFileTableViewCell.h"
#import "CWFTPFile.h"

NSString * kFileName = @"kCFFTPResourceName";
NSString * kFileSize = @"kCFFTPResourceSize";
NSString * kFileType = @"kCFFTPResourceType";

@implementation CWFileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier{
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

- (void)setFile:(CWFTPFile *)file{
    _file = file;
    [self reloadData];
}

- (void)reloadData{
    self.textLabel.text = self.file.resourceName;
    self.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:self.file.resourceSize
                                                               countStyle:NSByteCountFormatterCountStyleFile];
    
    BOOL isFolder = [self.file isDirectory];
    NSString *name = isFolder?@"Folder":@"File";
    self.imageView.image = [UIImage imageNamed:name];
    self.selectionStyle = isFolder?UITableViewCellSelectionStyleNone:UITableViewCellFocusStyleDefault;
}

@end
