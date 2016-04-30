//
//  CWHomeController.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWHomeController.h"
#import "CWFileTableViewCell.h"
#import "CWFileTableViewHeader.h"
#import "CWFileTableViewFooter.h"
#import "CWUploadController.h"

#import "CWFTPClient.h"

@interface CWHomeController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CWFileTableViewHeader *headerView;


@property (nonatomic, weak) CWFTPClient *ftpClient;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, assign, getter=isUploading) BOOL uploading;

@end

@implementation CWHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ftpClient = [CWFTPClient sharedClient];
    
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdges];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.title = self.ftpClient.username;
    self.hostName = self.ftpClient.host;
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(logoutButtonClick:)];
    self.navigationItem.rightBarButtonItem = logout;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.headerView.hostName = self.hostName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Clicks

- (void)uploadButtonClick:(id)sender{
    CWUploadController *vc = [CWUploadController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)logoutButtonClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CWFileTableViewCell class]
           forCellReuseIdentifier:@"Cell"];
        [_tableView registerClass:[CWFileTableViewFooter class]
           forHeaderFooterViewReuseIdentifier:@"Footer"];
    } return _tableView;
}

- (CWFileTableViewHeader *)headerView{
    if (!_headerView) {
        _headerView = [[CWFileTableViewHeader alloc] initWithReuseIdentifier:@"Header"];
    }return _headerView;
}



#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CWFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.file = self.files[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.isUploading?64.0f:30.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    [self.headerView setShowProgress:self.isUploading];
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CWFileTableViewFooter *footerView =  [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Footer"];
    if (!footerView.uploadButton.allTargets.count) {
        [footerView.uploadButton addTarget:self
                                     action:@selector(uploadButtonClick:)
                           forControlEvents:UIControlEventTouchUpInside];
    }return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
