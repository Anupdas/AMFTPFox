//
//  CWFileTableViewHeader.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFileTableViewHeader.h"

@interface CWFileTableViewHeader ()

@property (nonatomic, strong) UILabel *hostNameLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, assign) BOOL didLayoutConstraints;

@end

@implementation CWFileTableViewHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.hostNameLabel];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.infoLabel];
    }return self;
}

- (void)layoutSubviews{
    if (!self.didLayoutConstraints) {
        NSDictionary *views = @{@"host":self.hostNameLabel,
                                @"progress":self.progressView,
                                @"info":self.infoLabel};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"V:|-10-[host]-10-[progress]" options:0 metrics:nil views:views]];
        [self.hostNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-10-[progress]-10-[info(<=60)]-10-|" options:0 metrics:nil views:views]];
        [self.infoLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.progressView];
        
        self.didLayoutConstraints = YES;
    }[super layoutSubviews];
}
#pragma mark

- (void)setHostName:(NSString *)hostName{
    self.hostNameLabel.text = [NSString stringWithFormat:@"Server : %@",hostName];
}

- (void)setShowProgress:(BOOL)showProgress{
    self.progressView.hidden = !showProgress;
    self.infoLabel.hidden = !showProgress;
}

- (void)setProgressInfo:(NSDictionary *)progressInfo{
    self.progressView.progress = [progressInfo[@"Progress"] floatValue];
    
    NSInteger count = [progressInfo[@"Count"] integerValue];
    if (count) {
        self.infoLabel.text = [NSString stringWithFormat:@"%ld %@",count,count>1?@"Files":@"File"];
    }else{
        self.infoLabel.text = nil;
    }
}

#pragma mark

- (UILabel *)hostNameLabel{
    if (!_hostNameLabel) {
        _hostNameLabel = [UILabel newAutoLayoutView];
        _hostNameLabel.textColor = [UIColor darkGrayColor];
        _hostNameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _hostNameLabel.text = @"Server : ";
    }return _hostNameLabel;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [UIProgressView newAutoLayoutView];
    }return _progressView;
}

- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [UILabel newAutoLayoutView];
        _infoLabel.textColor = [UIColor grayColor];
        _infoLabel.font = [UIFont systemFontOfSize:15.0f];
    }return _infoLabel;
}


@end
