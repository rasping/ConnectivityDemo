//
//  SendFileViewController.m
//  Connectivity
//
//  Created by siping ruan on 17/1/9.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "SendFileViewController.h"
#import "AnimationView.h"
#import "Masonry.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "ProgressIconBtn.h"

@interface SendFileViewController ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (weak, nonatomic) UILabel *tipLable;
@property (weak, nonatomic) ProgressIconBtn *receiverBtn;

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) AnimationView *animationView;
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCNearbyServiceAdvertiser *nearbyServiceAdveriser;
@property (strong, nonatomic) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (strong, nonatomic) MCPeerID *peerID;

@end

@implementation SendFileViewController

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
    
    //使用注意：无论是接收者还是发送者都需要在广播数据的同时发送数据，方便发现对方建立连接回话；数据的传输必须要在回话建立完成后才能开始。
    
    self.title = @"发送文件";
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

#pragma mark - Public

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _filePath = filePath;
    }
    return self;
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
    [btn addTarget:self action:@selector(receiverBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:btn];
    self.receiverBtn = btn;
}

//扫描附近设备
- (void)scanNearbyPeer
{
    //开启扫描动画
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(clickAnimation) userInfo:nil repeats:YES];
    
    //创建回话(两边的回话类型必须一致)
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    
    //广播通知(广播是通过serviceType来区分，所以监听广播的serviceType必须相同，不然监听不到)
    self.nearbyServiceAdveriser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:nil serviceType:@"rsp-sender"];
    self.nearbyServiceAdveriser.delegate = self;
    [self.nearbyServiceAdveriser startAdvertisingPeer];
    
    //监听广播
    self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:@"rsp-receiver"];
    self.nearbyServiceBrowser.delegate = self;
    [self.nearbyServiceBrowser startBrowsingForPeers];
}

//扫描动画
-(void)clickAnimation
{
    CGFloat w = [UIScreen mainScreen].bounds.size.width - 60;
    AnimationView *animationView = [[AnimationView alloc] initWithFrame:CGRectMake(30, 150, w, w)];
    animationView.userInteractionEnabled = NO;
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

- (void)receiverBtnClicked:(UIButton *)btn
{
    //发出邀请
    //context 携带请求的附加信息
    [self.nearbyServiceBrowser invitePeer:self.peerID toSession:self.session withContext:nil timeout:30];
}

#pragma mark - MCNearbyServiceBrowserDelegate

// 发现了附近的广播节点
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    NSLog(@"发现了节点：%@", peerID.displayName);
    //这里只考虑一个节点的情况:发现节点就停止搜索
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
    //只有发送者发出邀请，接收者接收邀请
}

// 广播失败回调
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    [advertiser stopAdvertisingPeer];
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
            //这里利用数据源的方式来发送数据
            //这里必须要用fileURLWithPath 用String会报错Unsupported resource type
            NSProgress *progress = [self.session sendResourceAtURL:[NSURL fileURLWithPath:_filePath] withName:[_filePath lastPathComponent] toPeer:[self.session.connectedPeers firstObject] withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"发送源数据发生错误：%@", [error localizedDescription]);
                }else {
                    __weak typeof(self) ws = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws.receiverBtn setProgressValue:0];
                    });
                }
            }];
            [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
        }
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSString *data = @"hello";
    [self.session sendData:[data dataUsingEncoding:NSUTF8StringEncoding] toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
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
}

// 数据传输完成回调
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error
{
    NSLog(@"数据传输结束%@----%@", localURL.absoluteString, error);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = (NSProgress *)object;
    NSLog(@"%lf", progress.fractionCompleted);
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress.fractionCompleted > 0) {
            [ws.receiverBtn setProgressValue:progress.fractionCompleted];
        }
    });
    if (progress.fractionCompleted == 1.0) {
        [progress removeObserver:self forKeyPath:@"completedUnitCount" context:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"文件发送成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws.receiverBtn setProgressValue:0];
            }];
            [alert addAction:action];
            [ws presentViewController:alert animated:YES completion:^{
                //移除本地的临时文件
                NSFileManager *manager = [NSFileManager defaultManager];
                NSError *err = nil;
                BOOL ret = [manager removeItemAtPath:_filePath error:&err];
                if (!ret) {
                    NSLog(@"删除临时文件出错：err = %@", err.localizedDescription);
                }
            }];
        });
        
        //移除本地的临时文件
        //传输完成不能马上移除本地的临时文件，不然接收端会出现localURL参数为空  报错为：Peer no longer connected
//        NSFileManager *manager = [NSFileManager defaultManager];
//        NSError *err = nil;
//        BOOL ret = [manager removeItemAtPath:_filePath error:&err];
//        if (!ret) {
//            NSLog(@"删除临时文件出错：err = %@", err.localizedDescription);
//        }
    }
}

@end
