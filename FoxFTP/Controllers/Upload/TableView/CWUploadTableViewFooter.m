//
//  CWUploadTableViewFooter.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWUploadTableViewFooter.h"

@interface CWUploadTableViewFooter ()
@property (nonatomic, assign) BOOL didLayoutConstraints;
@end

@implementation CWUploadTableViewFooter

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.addFileButton];
    }return self;
}

- (void)layoutSubviews{
    if (!self.didLayoutConstraints) {
        [self.addFileButton autoCenterInSuperview];
        self.didLayoutConstraints = YES;
    }[super layoutSubviews];
}

- (UIButton *)addFileButton{
    if (!_addFileButton) {
        _addFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _addFileButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_addFileButton setTitle:@"Add File" forState:UIControlStateNormal];
        _addFileButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }return _addFileButton;
}

@end
