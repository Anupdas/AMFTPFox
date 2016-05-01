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
        _webView.scalesPageToFit = YES;
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

- (void)addDeleteButton{
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteFileButtonClick:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD dismiss];
    [self.ftpClient cancelDownloadRequest];
}

#pragma mark - Button Click

- (void)deleteFileButtonClick:(id)sender{
    [SVProgressHUD showWithStatus:@"Please wait..."];
    __weak CWDetailViewController *weakSelf = self;
    [self.ftpClient deleteFile:self.file
                    completion:^(id response, NSError *error) {
                        if (!error) {
                            [SVProgressHUD dismiss];
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }else{
                            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                        }
    }];
}

#pragma mark

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
    
    [self addDeleteButton];
}


@end
