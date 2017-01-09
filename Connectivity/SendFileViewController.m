//
//  SendFileViewController.m
//  Connectivity
//
//  Created by siping ruan on 17/1/9.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "SendFileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface SendFileViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)cancelBtnClicked:(UIBarButtonItem *)btn;
- (IBAction)photosBtnClicked:(UIButton *)btn;
- (IBAction)videosBtnClicked:(UIButton *)btn;

@end

@implementation SendFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

#pragma mark - Action

- (IBAction)cancelBtnClicked:(UIBarButtonItem *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)photosBtnClicked:(UIButton *)btn
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)videosBtnClicked:(UIButton *)btn
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSArray *array =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        picker.mediaTypes = array;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@", info);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
