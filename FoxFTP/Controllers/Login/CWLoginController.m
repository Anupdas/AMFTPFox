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
@property (nonatomic, strong) CWFTPClient *ftpClient;

@end

@implementation CWLoginController

#pragma mark

- (CWLoginView *)loginView{
    if (!_loginView) {
        _loginView = [CWLoginView newAutoLayoutView];
        [_loginView.loginButton addTarget:self
                                   action:@selector(loginButtonClick:)
                         forControlEvents:UIControlEventTouchUpInside];
        
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
    
    self.ftpClient = [CWFTPClient sharedClient];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Reset save switch
    self.loginView.saveSwitch.on = NO;
    
    if (self.ftpClient.credential) {
        self.loginView.usernameTextField.text = self.ftpClient.credential.username;
        self.loginView.passwordTextField.text  = self.ftpClient.credential.password;
        self.loginView.hostTextField.text = self.ftpClient.credential.host;
        [self signUserIn];
    }
    
    self.loginView.hostTextField.text     = @"52.26.67.76";
    self.loginView.usernameTextField.text = @"eauusers";
    self.loginView.passwordTextField.text = @"YTNhOTNmYTAwOTljYmFmMDlhMTJlODVl";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Validations

#pragma mark - Button Clicks

- (void)loginButtonClick:(id)sender{
    
    CWFTPClient *ftpClient = [CWFTPClient sharedClient];
    
    CWFTPCredential *credential = [CWFTPCredential new];
    credential.host     = self.loginView.hostTextField.text;
    credential.username = self.loginView.usernameTextField.text;
    credential.password = self.loginView.passwordTextField.text;
    
    [ftpClient signInWithCredential:credential
                               save:self.loginView.saveSwitch.isOn];
    
    
    [self signUserIn];
}

- (void)signUserIn{
    [SVProgressHUD showWithStatus:@"Connecting to Server..."];
    
    __weak CWLoginController *weakSelf = self;
    [self.ftpClient listContentsAtPath:@"/"
                              progress:^(float percentage) {
                                  [SVProgressHUD showProgress:percentage status:@"Downloading files..."];
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
