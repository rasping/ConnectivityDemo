//
//  LocalFileViewController.h
//  Connectivity
//
//  Created by siping ruan on 17/1/16.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalFileViewController;
@protocol LocalFileVCDelegate <NSObject>

@optional
/**
 选择了发送文件回调
 */
- (void)didSelectFilePath:(NSString *)path;
/**
 取消按钮点击
 */
- (void)localFileVCDidCancel:(LocalFileViewController *)localFileVC;

@end

@interface LocalFileViewController : UIViewController

@property (weak, nonatomic) id<LocalFileVCDelegate> delegate;
/**
 数据源数组("fileName"文件名 "fileSize"文件大小)
 */
@property (strong, nonatomic) NSArray<NSDictionary *> *dataArray;

@end

//本地文件名
extern NSString *const kLocalFileNameKey;
//本地文件大小
extern NSString *const kLocalFileSizeKey;
