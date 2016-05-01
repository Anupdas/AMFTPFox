//
//  CWUploadController.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWUploadController.h"
#import "CWUploadTableViewCell.h"
#import "CWUploadTableViewFooter.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import <Photos/Photos.h>

#import "CWFTPClient.h"
#import "CWFTPFile.h"

#import <KVOController/NSObject+FBKVOController.h>

@interface CWUploadController ()<UITableViewDataSource,UITableViewDelegate,
CTAssetsPickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *files;

@property (nonatomic, weak) CWFTPClient *ftpClient;

@end

@implementation CWUploadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Upload File";
    
    self.ftpClient = [CWFTPClient sharedClient];
    
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdges];
    
    [self addObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Button Click

- (void)addFileButtonClick:(id)sender{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

#pragma mark - Assets Library Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker
        didFinishPickingAssets:(NSArray *)assets{
    // assets contains PHAsset objects.
    
    if(assets.count){
        __weak CWUploadController *weakSelf = self;
        
        PHImageManager *imageManager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.version = PHImageRequestOptionsVersionOriginal;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        for (PHAsset *asset in assets) {
            [imageManager requestImageDataForAsset:asset
                                           options:options
                                     resultHandler:^(NSData * _Nullable imageData,
                                                     NSString * _Nullable dataUTI,
                                                     UIImageOrientation orientation,
                                                     NSDictionary * _Nullable info) {
                                         
                                         CWFTPFile *file = [self fileFromAssetInfo:info];
                                         file.resourceData = imageData;
                                         file.resourceSize = (int64_t)imageData.length;
                                         [weakSelf.ftpClient uploadFile:file];
                                     }];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (CWFTPFile *)fileFromAssetInfo:(NSDictionary *)info{
    CWFTPFile *file = [CWFTPFile new];
    file.fileID = [info[@"PHImageResultRequestIDKey"] integerValue];
    file.fileURL = info[@"PHImageFileURLKey"];
    
    //Find a non conflicting name
    NSString *fileName = file.fileURL.lastPathComponent;
    file.resourceName = [self.ftpClient.fileManager findUniqueFileName:fileName];
    return file;
}

#pragma mark - TableView

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CWUploadTableViewCell class]
           forCellReuseIdentifier:@"Cell"];
        [_tableView registerClass:[CWUploadTableViewFooter class]
           forHeaderFooterViewReuseIdentifier:@"Footer"];
    } return _tableView;
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CWUploadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.file = self.files[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CWUploadTableViewFooter *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Footer"];
    if (!footerView.addFileButton.allTargets.count) {
        [footerView.addFileButton addTarget:self
                                     action:@selector(addFileButtonClick:)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    return footerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50.0f;
}

#pragma mark - KVO

- (void)addObserver{
    __weak CWUploadController *weakSelf = self;
    [self.KVOController observe:self.ftpClient
                        keyPath:@"uploadCount"
                        options:NSKeyValueObservingOptionNew
                          block:^(CWUploadController *o, CWFTPClient *c, NSDictionary *change) {
                        [weakSelf performSelector:@selector(reloadTableView)
                                             withObject:nil
                                             afterDelay:1.0];
                          }];
}

- (void)reloadTableView{
    self.files = [self.ftpClient allUploadFiles];
    [self.tableView reloadData];
}


@end
