>Multipeer connectivity是一个使附近设备通过Wi-Fi网络、P2P Wi-Fi以及蓝牙个人局域网进行通信的框架。互相链接的节点可以安全地传递信息、流或是其他文件资源，而不用通过网络服务。

##概述
![多点连接](http://upload-images.jianshu.io/upload_images/1344789-8c3d1f98888e6b6a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
从上图中可以看出Multipeer Connectivity的功能与利用AirDrop传输文件非常类似，也可以将其看做是Apple对AirDrop不能直接开发的补偿，关于Multipeer Connectivity与AirDrop之间的对比，可参考[《MultipeerConnectivity.framework梳理》](http://blog.csdn.net/phunxm/article/details/43450167)
因为iOS系统中用户不能直接对文件进行操作，所以这个框架很少会在app中使用到。这就导致了网上很少有关于介绍这个框架的博文，至于可供参考的demo那就更加少之又少了。但这并不意味着这个技术不实用，像QQ的面对面快传(免流量)功能就是利用这个框架实现的。所以我利用这个框架实现了一个文件传输的demo，这里分享出来，供大家一起学习。
##实现功能
demo最终实现的效果图如下：
![效果图.jpeg](http://upload-images.jianshu.io/upload_images/1344789-16c95dfdd5799524.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
实现功能如下：
1.   可选择相册中的图片、视频进行传送
2.  可将想传送的文件移动到工程中LocaFile目录下，然后选择本地文件就可传送
3.  可扫描附近节点（只做了一个节点连接的情况 ）
4.  监控传输进度

##连接
要想让两个设备间能进行通信，必先让他们知道对象，这个过程就称之为连接。在Multipeer Connectivity框架中则是使用广播（Advertisting）和发现（Disconvering）模式来进行连接：假设有两台设备A、B，B作为广播去发送自身服务，A作为发现的客户端。一旦A发现了B就试图建立连接，经过B同意二者建立连接就可以相互发送数据。关于连接过程的更详尽介绍，可参考[《 iOS--MultipeerConnectivity蓝牙通讯》](http://blog.csdn.net/daiyibo123/article/details/48287079)。初始化代码如下
发送端代码：

```
   //创建会话
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    
    //监听广播
    self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:@"rsp-receiver"];
    self.nearbyServiceBrowser.delegate = self;
    [self.nearbyServiceBrowser startBrowsingForPeers];
```

接收端代码：

```
    //创建会话
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    self.session = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    
    //广播通知
    self.nearbyServiceAdveriser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:nil serviceType:@"rsp-receiver"];
    self.nearbyServiceAdveriser.delegate = self;
    [self.nearbyServiceAdveriser startAdvertisingPeer];
```
这里有三个地方需要注意：
1.  在初始化MCNearbyServiceAdvertiser 和MCNearbyServiceBrowser 对象时，传入的serviceType参数，这个参数必须满足：长度在1至15个字符之间，由ASCII字母、数字和“-”组成，不能以“-”为开头或结尾，不能包含除了“-“之外的其他特殊字符，否则会报MCErrorInvalidParameter错误。
2.  在监听广播通知时传入的参数serviceType必须与发送广播时传入的参数一致，否则无法监听到广播。
3.  发送端和接收端创建的会话对象类型和加密方式等必须一致，否则无法收到对方的连接请求。
初始化完成就要处理两端之间相互交互的逻辑了，具体代码如下：
发送端：

```
// 发现了附近的广播节点
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    //这里只考虑一个节点的情况:发现节点就停止搜索
    [browser stopBrowsingForPeers];
    self.peerID = peerID;
    //发出邀请
    [self.nearbyServiceBrowser invitePeer:self.peerID toSession:self.session withContext:nil timeout:30];
    //更新UI显示，
    [self showPeer];
}

// 广播节点丢失
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
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
}
```

这里需要注意：发出邀请有时间限制，当超出时限，接收端同意连接会报MCErrorTimedOut错误。
接收端：

```
// 收到节点邀请回调
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
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
   [advertiser stopAdvertisingPeer];
}
```
当收到发送端的连接请求时，就应该关闭广播通知
至此，双方通信链路协商成功，可以开始基于session向对方发送数据。
##数据发送
发送代码如下
发送端：

```
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
```

session提供了三种数据传输方式：普通数据传输(data)、数据流传输(streams)、数据源传输(resources)，这里使用第三种，关于三种数据传输方式的使用及场景，可参考[《 iOS--MultipeerConnectivity蓝牙通讯》](http://blog.csdn.net/daiyibo123/article/details/48287079)。
这里有两个地方需要注意：
1.  发送数据传入的resourceURL参数是文件在本地的路径，必须使用fileURLWithPath:创建，使用URLWithString:会报Unsupported resource type错误。
2.  因为传输的文件可能是临时文件，所以传输完成需要移除临时文件，但这里传输完成不能马上移除本地文件，否则接收端会在文件接收快要完成时会出现localURL参数为空  报错为：Peer no longer connected，具体原因不明。
接收端：

```
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
    if (error) {
        NSLog(@"数据传输结束%@----%@", localURL.absoluteString, error);
    }else {
        NSString *destinationPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:resourceName];
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
        //转移文件
        NSError *error1 = nil;
        if (![[NSFileManager defaultManager] moveItemAtURL:localURL toURL:destinationURL  error:&error1]) {
            NSLog(@"移动文件出错：error = %@", error1.localizedDescription);
        }else {
            __weak typeof(self) ws = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"%@", resourceName];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"文件接收成功" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:action];
                [ws presentViewController:alert animated:YES completion:nil];
            });
        }
    }
    
    //移除监听
    [self.progress removeObserver:self forKeyPath:@"completedUnitCount" context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = (NSProgress *)object;
    NSLog(@"%lf", progress.fractionCompleted);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.receiverBtn setProgressValue:progress.fractionCompleted];
    });
}
```
至此，一次文件传输就已完成。
##结尾
这里使用的是MCNearbyServiceAdvertiser和MCNearbyServiceBrowser来进行节点连接，当然还可以使用MCAdvertiserAssistant和MCBrowserViewController来进行节点连接，因为后者系统封装了一套标准的UI界面，所以集成起来更加简单，这里就不再赘述。
最后奉上[Demo地址](https://github.com/rasping/ConnectivityDemo)