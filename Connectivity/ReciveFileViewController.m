//
//  ReciveFileViewController.m
//  Connectivity
//
//  Created by siping ruan on 17/1/9.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "ReciveFileViewController.h"
#import "AnimationView.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ReciveFileViewController ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipLable;
@property (weak, nonatomic) IBOutlet UIButton *senderBtn;
- (IBAction)senderBtnClicked:(UIButton *)btn;

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) AnimationView *animationView;
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdveriser;
@property (strong, nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiser;
@property (strong, nonatomic) MCPeerID *peerID;

@end

@implementation ReciveFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self scanNearbyPeer];
    
    self.senderBtn.clipsToBounds = YES;
    self.senderBtn.layer.cornerRadius = 40;
}

#pragma mark - Action

- (IBAction)senderBtnClicked:(UIButton *)btn
{
    //发出邀请
    NSData *data = [self.nearbyServiceBrowser.myPeerID.displayName dataUsingEncoding:NSUTF8StringEncoding];
    [self.nearbyServiceBrowser invitePeer:self.peerID toSession:self.session withContext:data timeout:30];
}

#pragma mark - Private

//扫描附近设备
- (void)scanNearbyPeer
{
    //开启扫描动画
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(clickAnimation) userInfo:nil repeats:YES];
    
    //创建会话
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"接收者"];
    self.session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    
    //广播通知
    self.nearbyServiceAdveriser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:nil serviceType:@"rsp-receiver"];
    self.nearbyServiceAdveriser.delegate = self;
    [self.nearbyServiceAdveriser startAdvertisingPeer];
    
    //监听广播
    self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:@"rsp-sender"];
    self.nearbyServiceBrowser.delegate = self;
    [self.nearbyServiceBrowser startBrowsingForPeers];
}

//扫描动画
-(void)clickAnimation
{
    CGFloat w = [UIScreen mainScreen].bounds.size.width - 60;
    AnimationView *animationView = [[AnimationView alloc] initWithFrame:CGRectMake(30, 150, w, w)];
    animationView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:animationView];
    self.animationView = animationView;
    [UIView animateWithDuration:2 animations:^{
        animationView.transform=CGAffineTransformScale(animationView.transform, 4, 4);
        animationView.alpha=0;
    } completion:^(BOOL finished) {
        [animationView removeFromSuperview];
    }];
    
}

#pragma mark - MCNearbyServiceBrowserDelegate

// 发现了附近的广播节点
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    NSLog(@"发现了节点：%@", peerID.displayName);
    //这里只考虑一个节点的情况
    [browser stopBrowsingForPeers];
    
    //更新UI显示
    self.senderBtn.hidden = NO;
    self.tipLable.hidden = YES;
    self.animationView.hidden = YES;
    [self.timer invalidate];
    self.timer = nil;
    
    self.peerID = peerID;
}

// 广播节点丢失
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"丢失了节点：%@", peerID.displayName);
    //这里只考虑一个节点的情况
    [browser startBrowsingForPeers];
    
    //更新UI显示
    self.senderBtn.hidden = YES;
    self.tipLable.hidden = NO;
    self.animationView.hidden = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(clickAnimation) userInfo:nil repeats:YES];
}

// 搜索失败回调
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    [browser stopBrowsingForPeers];
    NSLog(@"搜索出错：%@", error.localizedDescription);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

// 收到节点邀请回调
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
    NSLog(@"收到%@节点的连接请求", peerID.displayName);
    [advertiser stopAdvertisingPeer];
    
    //交互选择框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@请求与你建立连接", peerID.displayName] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *accept = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        invitationHandler(YES, self.session);
    }];
    [alert addAction:accept];
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        invitationHandler(NO, self.session);
    }];
    [alert addAction:reject];
    [self presentViewController:alert animated:YES completion:nil];
}

// 广播失败回调
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"%@节点广播失败", advertiser.myPeerID.displayName);
}

#pragma mark - MCSessionDelegate

// 会话状态改变回调
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateNotConnected://未连接
            NSLog(@"未连接");
            break;
        case MCSessionStateConnecting://连接中
            NSLog(@"连接中");
            break;
        case MCSessionStateConnected://连接完成
        {
            NSLog(@"连接完成");
        }
            break;
    }
}

// 普通数据传输
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"普通数据%@", peerID.displayName);
}

// 数据流传输
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"数据流%@", peerID.displayName);
}

// 数据源传输开始
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"数据传输开始");
    //KVO观察
    [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
}

// 数据传输完成回调
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error
{
    NSLog(@"数据传输结束");
    NSString *destinationPath = @"/Users/sipingruan/Desktop/test";
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    //判断文件是否存在，存在则删除
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:destinationPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    }
    //转移文件
    NSError *error1 = nil;
    if (![[NSFileManager defaultManager] moveItemAtURL:localURL toURL:destinationURL  error:&error1]) {
        NSLog(@"[Error] %@", error1);
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = (NSProgress *)object;
    dispatch_async(dispatch_get_main_queue(), ^{
        int64_t numberCom = progress.completedUnitCount;
        int64_t numberTotal = progress.totalUnitCount;
        NSLog(@"%lld/%lld", numberCom, numberTotal);
    });
}

@end
