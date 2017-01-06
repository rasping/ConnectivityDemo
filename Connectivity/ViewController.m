//
//  ViewController.m
//  Connectivity
//
//  Created by siping ruan on 17/1/6.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //MultipeerConnectivity.framework了解
//    MCAdvertiserAssistant //广播助手类 可以接收，并处理用户请求连接的响应。没有回调，会弹出默认的提示框，并处理连接
    
//    MCNearbyServiceAdvertiser //附近广播服务类 可以接收并处理用户连接的响应。但是，这个类会有回调，告知用户要与你的设备连接，然后可以自定义提示框，以及自定义连接处理
//    MCNearbyServiceBrowser //附近搜索服务类 用于所搜附近的用户，并可以对搜索到的用户发出邀请加入某个回话中
//    MCPeerID //点ID类 代表一个用户
//    MCSession //回话类 启用和管理Multipeer连接回话中的所有人之间的沟通通过Session个别人发送数据
//    MCBrowserViewController //提供一个标准的用户界面 该界面允许用户进行选择附近设备peer来加入一个session
    
    //注意：根据serviceType创建的对象，该serviceType命名规则：serviceType=由ASCII字母、数字和“-”组成的短文本串，最多15个字符。通常，一个服务的名字应该由应用程序的名字开始，后边跟“-”和一个独特的描述符号。如果不符合，会报错的。
    
}


@end
