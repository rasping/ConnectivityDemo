//
//  SendFileViewController.h
//  Connectivity
//
//  Created by siping ruan on 17/1/9.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendFileViewController : UIViewController

/**
 文件路径
 */
@property (copy, nonatomic, readonly) NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath;

@end
