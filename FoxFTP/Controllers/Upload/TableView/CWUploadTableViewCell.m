//
//  CWUploadTableViewCell.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWUploadTableViewCell.h"
#import "CWFTPClient.h"
#import "CWFTPFile.h"
#import <KVOController/NSObject+FBKVOController.h>

@interface CWUploadTableViewCell ()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, assign) BOOL didLayoutConstraints;

@end

@implementation CWUploadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.fileNameLabel];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.cancelButton];
        
    }return self;
}

- (void)layoutSubviews{
    if (!self.didLayoutConstraints) {
        
        NSDictionary *views = @{@"name":self.fileNameLabel,
                                @"cancel":self.cancelButton,
                                @"progress":self.progressView};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"V:|-5-[name]-10-[progress]-5-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-10-[name]-10-[cancel]-10-|" options:0 metrics:nil views:views]];
        [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0f];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-10-[progress]-10-|" options:0 metrics:nil views:views]];
        
        self.didLayoutConstraints = YES;
    }[super layoutSubviews];
}

#pragma mark - 

- (void)setFile:(CWFTPFile *)file{
    if (self.file == file) return;
    
    _file = file;
    [self reloadData];
    
    __weak CWUploadTableViewCell *weakSelf = self;
    [self.KVOController observe:file keyPath:@"progress"
                        options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                          block:^(CWUploadTableViewCell *cell, CWFTPFile *file, NSDictionary *change) {
                          // update observer with new value
                          CGFloat progress = [change[NSKeyValueChangeNewKey] floatValue];
                          [weakSelf setProgress:progress];
                      }];
}

- (void)reloadData{
    self.fileNameLabel.text = self.file.resourceName;
}

- (void)setProgress:(CGFloat)progress{
    self.progressView.progress = progress;
    
    BOOL hide = progress == 1;
    self.cancelButton.hidden = hide;
    self.progressView.hidden = hide;
}

#pragma mark -

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                          action:@selector(cancelButtonClick:)
                forControlEvents:UIControlEventTouchUpInside];
    }return _cancelButton;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [UIProgressView newAutoLayoutView];
        _progressView.progress = 0.5f;
    }return _progressView;
}

- (UILabel *)fileNameLabel{
    if (!_fileNameLabel) {
        _fileNameLabel = [UILabel newAutoLayoutView];
        _fileNameLabel.textColor = [UIColor darkGrayColor];
        _fileNameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    }return _fileNameLabel;
}

#pragma mark - Button Click

- (void)cancelButtonClick:(id)sender{
    [[CWFTPClient sharedClient] cancelUploadFile:self.file];
}

@end
