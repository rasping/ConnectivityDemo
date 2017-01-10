//
//  SendFileViewController.m
//  Connectivity
//
//  Created by siping ruan on 17/1/9.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "SendFileViewController.h"
#import "AnimationView.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface SendFileViewController ()<MCSessionDelegate, MCBrowserViewControllerDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *tipLable;
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCBrowserViewController *browserController;

@end

@implementation SendFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"发送文件";
    [self scanNearbyPeer];
}

#pragma mark - Public

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _filePath = filePath;
    }
    return self;
}

#pragma mark - Private

//扫描动画
-(void)clickAnimation
{
    CGFloat w = [UIScreen mainScreen].bounds.size.width - 60;
    AnimationView *animationView = [[AnimationView alloc] initWithFrame:CGRectMake(30, 150, w, w)];
    animationView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:animationView];
    [UIView animateWithDuration:2 animations:^{
        animationView.transform=CGAffineTransformScale(animationView.transform, 4, 4);
        animationView.alpha=0;
    } completion:^(BOOL finished) {
        [animationView removeFromSuperview];
    }];
    
}

//扫描附近设备
- (void)scanNearbyPeer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(clickAnimation) userInfo:nil repeats:YES];
    
    MCPeerID *peerID = [[MCPeerID alloc]initWithDisplayName:@"发送者"];
    self.session = [[MCSession alloc] initWithPeer:peerID];
    self.session.delegate = self;
    
    self.browserController = [[MCBrowserViewController alloc] initWithServiceType:@"rsp-Sender" session:self.session];
    self.browserController.delegate = self;
    [self presentViewController:self.browserController animated:YES completion:nil];
}

#pragma mark - MCBrowserViewControllerDelegate

// Notifies the delegate, when the user taps the done button.
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    
}

// Notifies delegate that a peer was found; discoveryInfo can be used to
// determine whether the peer should be presented to the user, and the
// delegate should return a YES if the peer should be presented; this method
// is optional, if not implemented every nearby peer will be presented to
// the user.
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController
      shouldPresentNearbyPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    return YES;
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


@end
