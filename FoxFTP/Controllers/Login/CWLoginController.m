//
//  CWLoginController.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWLoginController.h"
#import "CWLoginView.h"
#import "CWFTPClient.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "CWHomeController.h"

@interface CWLoginController ()

@property (nonatomic, strong) CWLoginView *loginView;

@end

@implementation CWLoginController

#pragma mark

- (CWLoginView *)loginView{
    if (!_loginView) {
        _loginView = [CWLoginView newAutoLayoutView];
        [_loginView.loginButton addTarget:self
                                   action:@selector(loginButtonClick:)
                         forControlEvents:UIControlEventTouchUpInside];
        
        if (TARGET_IPHONE_SIMULATOR) {
            _loginView.hostTextField.text = @"52.26.67.76";
            _loginView.usernameTextField.text = @"eauusers";
            _loginView.passwordTextField.text = @"YTNhOTNmYTAwOTljYmFmMDlhMTJlODVl";
        }
    }return _loginView;
}

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|
    UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    
    [self.view addSubview:self.loginView];
    [self.loginView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Validations

#pragma mark - Button Clicks

- (void)loginButtonClick:(UIButton *)button{
    
    CWFTPClient *ftpClient = [CWFTPClient sharedClient];
    ftpClient.host = self.loginView.hostTextField.text;
    ftpClient.username = self.loginView.usernameTextField.text;
    ftpClient.password = self.loginView.passwordTextField.text;
    
    [SVProgressHUD showWithStatus:@"Connecting to Server..."];
    
    __weak CWLoginController *weakSelf = self;
    [ftpClient listContentsAtPath:@"/"
                         progress:^(float percentage) {
                             //[SVProgressHUD showProgress:percentage status:@"Downloading Contents"];
    }   completion:^(id response, NSError *error) {
        if ([response isKindOfClass:[NSArray class]]) {
            
            [SVProgressHUD dismiss];
            
            CWHomeController *vc = [CWHomeController new];
            vc.files = (NSArray *)response;
            [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        }else{
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
    
}

@end
