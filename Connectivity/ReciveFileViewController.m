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
#import "ProgressIconBtn.h"
#import "Masonry.h"

@interface ReciveFileViewController ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (weak, nonatomic) UILabel *tipLable;
@property (weak, nonatomic) ProgressIconBtn *receiverBtn;

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) AnimationView *animationView;
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdveriser;
@property (strong, nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) NSProgress *progress;

@end

@implementation ReciveFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addOwnViews];
    [self scanNearbyPeer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.receiverBtn.hidden) {
        self.receiverBtn.hidden = YES;
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.nearbyServiceAdveriser) {
        [self.nearbyServiceAdveriser stopAdvertisingPeer];
    }
    if (self.nearbyServiceBrowser) {
        [self.nearbyServiceBrowser stopBrowsingForPeers];
    }
}

#pragma mark - Private

- (void)addOwnViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //tipLable
    UILabel *lable = [[UILabel alloc] init];
    lable.text = @"正在搜索附近的设备...";
    lable.textColor = [UIColor colorWithRed:23/255.0 green:1.0 blue:1.0 alpha:1.0];
    [self.view addSubview:lable];
    __weak typeof(self) ws = self;
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view.mas_centerX);
        make.top.offset(100);
    }];
    
    //progressIconBtn
    ProgressIconBtn *btn = [[ProgressIconBtn alloc] init];
    CGFloat btnWH = 100;
    btn.frame = CGRectMake(0, 0, btnWH, btnWH);
    btn.center = CGPointMake(self.view.center.x, 180);
    btn.backgroundColor = [UIColor clearColor];
    btn.hidden = YES;
//    [btn addTarget:self action:@selector(senderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:btn];
    self.receiverBtn = btn;
}

//扫描附近设备
- (void)scanNearbyPeer
{
    //开启扫描动画
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(clickAnimation) userInfo:nil repeats:YES];
    
    //创建会话
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    self.session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
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

//显示扫描到的节点
- (void)showPeer
{
    self.receiverBtn.hidden = NO;
    self.receiverBtn.nickName.text = self.peerID.displayName;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1.5f;
    transition.type = @"rippleEffect";
    [self.receiverBtn.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.receiverBtn];
}

//隐藏扫描到的节点
- (void)hidePeer
{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.5f;
    transition.type = @"rippleEffect";
    [self.receiverBtn.layer addAnimation:transition forKey:nil];
    [self.view bringSubviewToFront:self.receiverBtn];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.receiverBtn.hidden = YES;
    });
}

#pragma mark - Action

- (void)senderBtnClicked:(UIButton *)btn
{
    //发出邀请
    NSData *data = [self.nearbyServiceBrowser.myPeerID.displayName dataUsingEncoding:NSUTF8StringEncoding];
    [self.nearbyServiceBrowser invitePeer:self.peerID toSession:self.session withContext:data timeout:30];
}

#pragma mark - MCNearbyServiceBrowserDelegate

// 发现了附近的广播节点
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    NSLog(@"发现了节点：%@", peerID.displayName);
    //这里只考虑一个节点的情况
    [browser stopBrowsingForPeers];
    
    self.peerID = peerID;
    
    //更新UI显示
    [self showPeer];
}

// 广播节点丢失
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"丢失了节点：%@", peerID.displayName);
    //这里只考虑一个节点的情况
    [browser startBrowsingForPeers];
    
    self.peerID = nil;
    
    //更新UI显示
    [self hidePeer];
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
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        invitationHandler(NO, self.session);
    }];
    [alert addAction:reject];
    UIAlertAction *accept = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        invitationHandler(YES, self.session);
    }];
    [alert addAction:accept];
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
    self.receiverBtn.state = (BtnState)state;
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
    NSLog(@"普通数据%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
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
    self.progress = progress;
    [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
}

// 数据传输完成回调
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error
{
    NSLog(@"数据传输结束%@", localURL.absoluteString);
    
    [self.nearbyServiceAdveriser stopAdvertisingPeer];
    [self.nearbyServiceBrowser stopBrowsingForPeers];
    [session disconnect];
    [self.progress removeObserver:self forKeyPath:@"completedUnitCount" context:nil];
    
//    NSString *destinationPath = @"/Users/sipingruan/Desktop/test";
//    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
//    //判断文件是否存在，存在则删除
//    if ([[NSFileManager defaultManager] isDeletableFileAtPath:destinationPath]) {
//        [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
//    }
//    //转移文件
//    NSError *error1 = nil;
//    if (![[NSFileManager defaultManager] moveItemAtURL:localURL toURL:destinationURL  error:&error1]) {
//        NSLog(@"[Error] %@", error1);
//    }
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
