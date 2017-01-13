//
//  ViewController.m
//  Connectivity
//
//  Created by siping ruan on 17/1/6.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "ViewController.h"
#import "SendFileViewController.h"
#import "ReciveFileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ProgressIconBtn.h"
#import <Photos/Photos.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)sendBtnClicked:(UIButton *)btn;

@property (copy, nonatomic) NSURL *referenceURL;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    ProgressIconBtn *btn = [[ProgressIconBtn alloc] init];
//    btn.backgroundColor = [UIColor redColor];
//    btn.frame = CGRectMake(0, 0, 100, 100);
//    btn.center = self.view.center;
//    [self.view addSubview:btn];
}

#pragma mark - Action

- (IBAction)sendBtnClicked:(UIButton *)btn
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) ws = self;
    UIAlertAction *photosAction = [UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws accessLocaResource:(NSString *)kUTTypeImage];
    }];
    [alertView addAction:photosAction];
    UIAlertAction *videosAction = [UIAlertAction actionWithTitle:@"本地视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws accessLocaResource:(NSString *)kUTTypeMovie];
    }];
    [alertView addAction:videosAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:cancelAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - Private

//访问本地资源
- (void)accessLocaResource:(NSString *)type
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes =  [[NSArray alloc] initWithObjects:type, nil];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //将选取到的资源存储到临时文件夹中，在发送
    NSURL *refrenceURL = info[UIImagePickerControllerReferenceURL];
    AVAsset *avasset = [AVAsset assetWithURL:refrenceURL];
    NSLog(@"%@", avasset);
    [self dismissViewControllerAnimated:YES completion:^{
        SendFileViewController *sendFileVC = [[SendFileViewController alloc] initWithFilePath:self.referenceURL];
        [self.navigationController pushViewController:sendFileVC animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
