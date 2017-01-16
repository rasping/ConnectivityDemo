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
#import "LocalFileViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, LocalFileVCDelegate>

- (IBAction)sendBtnClicked:(UIButton *)btn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
/**
 存放本地文件的文件夹路径
 */
@property (copy, nonatomic) NSString *locaFilePath;

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
    UIAlertAction *localAction = [UIAlertAction actionWithTitle:@"本地文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LocalFile"];
        self.locaFilePath = path;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *subPaths = [manager subpathsOfDirectoryAtPath:path error:&error];
        if (error) {
            NSLog(@"读取本地文件出错：%@", error);
        }else {
            [ws.indicatorView startAnimating];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *dataArray = [NSMutableArray array];
                for (NSString *subPath in subPaths) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:subPath forKey:kLocalFileNameKey];
                    NSError *error = nil;
                    NSFileManager *manager = [NSFileManager defaultManager];
                    NSDictionary *attrs = [manager attributesOfItemAtPath:[self.locaFilePath stringByAppendingPathComponent:subPath] error:&error];
                    if (error) {
                        NSLog(@"读取文件属性出错：error = %@", error);
                    }else {
                        [dict setObject:[NSString stringWithFormat:@"%@", attrs[NSFileSize]] forKey:kLocalFileSizeKey];
                    }
                    [dataArray addObject:dict];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws.indicatorView stopAnimating];
                    LocalFileViewController *locaFileVC = [[LocalFileViewController alloc] init];
                    locaFileVC.dataArray = dataArray;
                    locaFileVC.delegate = self;
                    [ws presentViewController:locaFileVC animated:YES completion:nil];
                });
            });
        }
    }];
    [alertView addAction:localAction];
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
    //因为相册中的文件不能直接访问，所以需要将选取到的资源存储到临时文件夹中，再发送
    NSString *mediaType = (NSString *)info[UIImagePickerControllerMediaType];
    [self.indicatorView startAnimating];
    self.view.userInteractionEnabled = NO;
    __weak typeof(self) ws = self;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //存储图片文件
            UIImage *tempImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
            NSData *pngData = UIImageJPEGRepresentation(tempImage, 1.0);
            NSDateFormatter *inFormat = [NSDateFormatter new];
            [inFormat setDateFormat:@"yyMMdd-HHmmss"];
            NSString *imageName = [NSString stringWithFormat:@"image-%@.JPG", [inFormat stringFromDate:[NSDate date]]];
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
            [pngData writeToFile:tempPath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.indicatorView stopAnimating];
                ws.view.userInteractionEnabled = YES;
                [ws dismissViewControllerAnimated:YES completion:^{
                    SendFileViewController *sendFileVC = [[SendFileViewController alloc] initWithFilePath:tempPath];
                    [ws.navigationController pushViewController:sendFileVC animated:YES];
                }];
            });
        });
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //存储视频文件
            NSURL *videoUrl = (NSURL *)info[UIImagePickerControllerMediaURL];
            NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
            NSDateFormatter *inFormat = [NSDateFormatter new];
            [inFormat setDateFormat:@"yyMMdd-HHmmss"];
            NSString *videoName = [NSString stringWithFormat:@"video-%@.%@", [inFormat stringFromDate:[NSDate date]], videoUrl.lastPathComponent];
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
            [videoData writeToFile:tempPath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.indicatorView stopAnimating];
                ws.view.userInteractionEnabled = YES;
                [ws dismissViewControllerAnimated:YES completion:^{
                    SendFileViewController *sendFileVC = [[SendFileViewController alloc] initWithFilePath:tempPath];
                    [ws.navigationController pushViewController:sendFileVC animated:YES];
                }];
            });
        });
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LocalFileVCDelegate

- (void)didSelectFilePath:(NSString *)path
{
    __weak typeof(self) ws = self;
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *filePath = [self.locaFilePath stringByAppendingString:path];
        SendFileViewController *sendFileVC = [[SendFileViewController alloc] initWithFilePath:filePath];
        [ws.navigationController pushViewController:sendFileVC animated:YES];
    }];
}

- (void)localFileVCDidCancel:(LocalFileViewController *)localFileVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
