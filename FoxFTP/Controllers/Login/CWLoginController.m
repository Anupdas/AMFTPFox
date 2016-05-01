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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.ftpClient.credential || TARGET_IPHONE_SIMULATOR) {
        self.loginView.usernameTextField.text = TARGET_IPHONE_SIMULATOR?
        @"eauusers":self.ftpClient.credential.username;
        
        self.loginView.passwordTextField.text  = TARGET_IPHONE_SIMULATOR?
        @"YTNhOTNmYTAwOTljYmFmMDlhMTJlODVl":self.ftpClient.credential.password;
        
        self.loginView.hostTextField.text = TARGET_IPHONE_SIMULATOR?
        @"52.26.67.76":self.ftpClient.credential.host;
        
        if (TARGET_IPHONE_SIMULATOR) {
            [self loginButtonClick:nil];
        }else{
            [self signUserIn];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Validations

#pragma mark - Button Clicks

- (void)loginButtonClick:(UIButton *)button{
    
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
