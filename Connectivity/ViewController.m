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
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate>

- (IBAction)sendBtnClicked:(UIButton *)btn;

@property (strong,nonatomic) MCSession *session;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@property (strong,nonatomic) MCBrowserViewController *browserController;
@property (copy, nonatomic) NSString *referenceURL;

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
    self.referenceURL = info[UIImagePickerControllerReferenceURL];
    [self dismissViewControllerAnimated:YES completion:^{
        MCPeerID *peerID=[[MCPeerID alloc]initWithDisplayName:@"发送者"];
        //创建会话
        self.session = [[MCSession alloc]initWithPeer:peerID];
        self.session.delegate = self;
        
        //开启广播
        self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"rsp-sender" discoveryInfo:nil session:_session];
        _advertiserAssistant.delegate = self;
        // Start the assistant to begin advertising your peers availability
        [_advertiserAssistant start];
        
        //展示附近设备列表
        self.browserController = [[MCBrowserViewController alloc]initWithServiceType:@"rsp-sender" session:self.session];
        self.browserController.delegate = self;
        [self presentViewController:self.browserController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MCBrowserViewControllerDelegate

// 完成按钮点击回调
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}

// 取消按钮点击回调
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    return YES;
}

#pragma mark - MCAdvertiserAssistantDelegate

// An invitation will be presented to the user.
- (void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    
}

// An invitation was dismissed from screen.
- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    
}

#pragma mark - MCSessionDelegate

// 回话状态改变回调
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
}

// 普通数据传输
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
}

// 数据流传输
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// 数据源传输
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// 数据传输完成回调
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error
{
    
}

//回话收到证书回调
- (void)session:(MCSession *)session didReceiveCertificate:(nullable NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    
}

@end
