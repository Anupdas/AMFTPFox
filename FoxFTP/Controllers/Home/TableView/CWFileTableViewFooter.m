//
//  CWFileTableViewFooter.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWFileTableViewFooter.h"

@interface CWFileTableViewFooter ()
@property (nonatomic, assign) BOOL didLayoutConstraints;
@end

@implementation CWFileTableViewFooter

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.uploadButton];
    }return self;
}

- (void)layoutSubviews{
    if (!self.didLayoutConstraints) {
        [self.uploadButton autoCenterInSuperview];
        self.didLayoutConstraints = YES;
    }[super layoutSubviews];
}

- (UIButton *)uploadButton{
    if (!_uploadButton) {
        _uploadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _uploadButton.translatesAutoresizingMaskIntoConstraints = YES;
        [_uploadButton setTitle:@"Upload File" forState:UIControlStateNormal];
        _uploadButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }return _uploadButton;
}

@end
