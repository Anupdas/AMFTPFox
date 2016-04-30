//
//  CWUploadTableViewCell.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWUploadTableViewCell.h"

NSString * kUploadFileName = @"kCFFTPResourceName";

@interface CWUploadTableViewCell ()

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
                                          @"V:|-10-[name]-10-[progress]-10-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-10-[name]-10-[cancel]-10-|" options:0 metrics:nil views:views]];
        [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0f];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-10-[progress]-10-" options:0 metrics:nil views:views]];
        
        self.didLayoutConstraints = YES;
    }[super layoutSubviews];
}

#pragma mark - 

- (void)setFile:(NSDictionary *)file{
    _file = file;
    [self reloadData];
}

- (void)reloadData{
    self.fileNameLabel.text = self.file[kUploadFileName];
}

- (void)setProgress:(CGFloat)progress{
    self.progressView.progress = progress;
}

#pragma mark - 

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }return _cancelButton;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [UIProgressView newAutoLayoutView];
    }return _progressView;
}

- (UILabel *)fileNameLabel{
    if (!_fileNameLabel) {
        _fileNameLabel = [UILabel newAutoLayoutView];
        _fileNameLabel.textColor = [UIColor darkGrayColor];
        _fileNameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    }return _fileNameLabel;
}


@end
