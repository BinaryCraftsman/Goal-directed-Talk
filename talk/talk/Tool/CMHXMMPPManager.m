//
//  CMHXMMPPManager.m
//  talk
//
//  Created by mac on 2016/11/30.
//  Copyright © 2016年 常明会. All rights reserved.
//

#import "CMHXMMPPManager.h"
#import "XMPPLogging.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

static CMHXMMPPManager *instance;
@interface CMHXMMPPManager () <XMPPStreamDelegate, XMPPAutoPingDelegate, XMPPReconnectDelegate>
//数据流，核心类
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, copy) NSString *passWord;
//是注册还是登录
@property (nonatomic, assign) BOOL registerAccount;
//心跳检测模块
@property (nonatomic, strong) XMPPAutoPing *xmppAutoping;
//自动重连模块
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@end



@implementation CMHXMMPPManager

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CMHXMMPPManager new];
        //设置xmpp传输日志
        [instance setupLogging];
        //设置模块
        [instance setupModule];
    });
    return instance;
}
//设置模块
- (void)setupModule{
    //使用XEP协议时，选择对应的模块，模块的使用方式：1.创建模块对象  2.设置属性、代理   3.激活模块
    /*
     心跳模块
     */
    //心跳包的发送时间间隔
    self.xmppAutoping.pingInterval = 5;
    //心跳包的相应时限
    self.xmppAutoping.pingTimeout = 3;
    //是否相应对端的心跳包
    self.xmppAutoping.respondsToQueries = YES;
//    [self.xmppAutoping activate:self.xmppStream];
    /*
     自动重连模块
     */
    //首次断开连接后重连的延迟时间
    self.xmppReconnect.reconnectDelay = 1;
    //重连失败后定时进行重连
    self.xmppReconnect.reconnectTimerInterval = 1;
    [self.xmppReconnect activate:self.xmppStream];
}
- (void)setupLogging{
    //设置日志类型&级别
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
}
//注册
- (void)registerWithJID:(XMPPJID *)jid andPassword:(NSString *)password{
    self.registerAccount = YES;
    [self connectWithJID:jid andPassword:password];
}
//登录
-(void)loginWithJID:(XMPPJID *)jid andPassword:(NSString *)password{
    [self connectWithJID:jid andPassword:password];
}
//建立连接
- (void)connectWithJID:(XMPPJID *)jid andPassword:(NSString *)password{
    //建立长连接
    //设置IP地址&端口号&jid
    self.xmppStream.hostName = @"127.0.0.1";
    self.xmppStream.hostPort = 5222;
    self.xmppStream.myJID = jid;
    self.passWord = password;
    [self.xmppStream connectWithTimeout:-1 error:nil];
}
#pragma mark - XMPPStreamDelegate
//建立长连接后调用
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"建立连接");
    //判断是注册还是登录
    if (self.registerAccount) {//注册
        [self.xmppStream registerWithPassword:self.passWord error:nil];
    } else {
        //进行登录
        [self.xmppStream authenticateWithPassword:self.passWord error:nil];
    }
}
#pragma mark - XMPPReconnectDelegate
//已经检测到非正常连接后调用
//- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags{
//    //systemconfigration是最底层的获取网络状态的类库（c语言）->reachability(oc ios类库，但是不在xcode打包下载的api中)->AFN检测网络连接状态就是使用的reachability类库
//    
//}
////设置是否应该以自动重连时调用（可能会根据网络情况的不同选择是否自动重联服务器）
//- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags{
//    return YES;
//}
#pragma mark - XMPPAutoPingDelegate
//已经发送心跳包后调用
-(void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender{
    NSLog(@"发送心跳包后调用");
}
//已经接收到心跳报的相应后调用
-(void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender{
    NSLog(@"接收到心跳包相应");
}
//已经注册成功后调用
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
}
//心跳包超时后调用
-(void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender{
    NSLog(@"连接出现问题");
    //可以直接断开连接，再重新连接
    [self.xmppStream disconnect];//系统有自动重连模块，会自动重新连接
}





//已经登陆后调用
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"登录成功");
    //设置在线状态 使用presence字节
//    XMPPPresence *presence = [[XMPPPresence alloc] initWithXMLString:@"<presence type='available'><show>dnd</show></presence>" error:nil];
    //添加子节点
    XMPPPresence *presence = [XMPPPresence presence];//此处默认的presence状态为：available
    //设置预制类型
    [presence addChild:[XMPPElement elementWithName:@"show" stringValue:@"dnd"]];
    //设置自定义内容（必须先设置预制类型）,类似QQ的说说
    [presence addChild:[XMPPElement elementWithName:@"status" stringValue:@"闭关，勿扰！"]];
    [self.xmppStream sendElement:presence];
    
}
#pragma mark - 懒加载
- (XMPPStream *)xmppStream{
    if ( _xmppStream == nil) {
       _xmppStream = [[XMPPStream alloc] init];
        //设置代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppStream;
}
- (XMPPAutoPing *)xmppAutoping{
    if (_xmppAutoping == nil) {
       _xmppAutoping = [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
        //设置代理，监听心跳情况
        [_xmppAutoping addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppAutoping;
}
-(XMPPReconnect *)xmppReconnect{
    if (_xmppReconnect == nil) {
       _xmppReconnect = [[XMPPReconnect alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
        //设置代理
        [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppReconnect;
}
@end
