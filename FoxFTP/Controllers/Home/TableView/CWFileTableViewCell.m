//
//  CWFileTableViewCell.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFileTableViewCell.h"

NSString * kFileName = @"kCFFTPResourceName";
NSString * kFileSize = @"kCFFTPResourceSize";
NSString * kFileType = @"kCFFTPResourceType";

@implementation CWFileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier{
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

- (void)setFile:(NSDictionary *)file{
    _file = file;
    [self reloadData];
}

- (void)reloadData{
    self.textLabel.text = self.file[kFileName];
    self.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:[self.file[kFileSize] longLongValue]
                                                               countStyle:NSByteCountFormatterCountStyleFile];
    NSString *name = [self.file[kFileType] integerValue] == 8?@"Folder":@"File";
    self.imageView.image = [UIImage imageNamed:name];
}

@end
