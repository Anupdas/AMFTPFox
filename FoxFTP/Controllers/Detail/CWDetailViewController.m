//
//  CWDetailViewController.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 01/05/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWDetailViewController.h"
#import "CWFTPClient.h"
#import "CWFTPFile.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface CWDetailViewController ()

@property (nonatomic, strong) CWFTPFile *file;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, weak) CWFTPClient *ftpClient;

@end

@implementation CWDetailViewController

- (instancetype)initWithFile:(CWFTPFile *)file{
    self = [super init];
    if (self) {
        _file = file;
    }return self;
}

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [UIWebView newAutoLayoutView];
    }return _webView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.ftpClient = [CWFTPClient sharedClient];
    
    [self.view addSubview:self.webView];
    [self.webView autoPinEdgesToSuperviewEdges];
    
    self.title = self.file.resourceName;
    
    [self fetchResourceIfRequired];
    
}

- (void)fetchResourceIfRequired{
    if ([self.ftpClient.fileManager localFileExistsAtPath:self.file.resourceName]) {
        [self loadResource];
    }else{
        __weak CWDetailViewController *weakSelf = self;
        [SVProgressHUD showWithStatus:@"Please wait..."];
        [self.ftpClient downloadFile:self.file.resourceName
                            progress:^(float percentage) {
                                [SVProgressHUD showProgress:percentage status:@"Downloading file"];
                            } completion:^(id response, NSError *error) {
                                if (!error) {
                                    [weakSelf loadResource];
                                }
                                
                                [SVProgressHUD dismiss];
                            }];
    }
}

- (void)loadResource{
    NSURL *fileURL = [self.ftpClient.fileManager localFileURLForResourceName:self.file.resourceName];
    [self.webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
}


@end
