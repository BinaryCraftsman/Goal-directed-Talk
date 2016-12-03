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
@interface CMHXMMPPManager () <XMPPStreamDelegate>
//数据流，核心类
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, copy) NSString *passWord;
//是注册还是登录
@property (nonatomic, assign) BOOL registerAccount;
@end



@implementation CMHXMMPPManager

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CMHXMMPPManager new];
        //设置xmpp传输日志
        [instance setupLogging];
    });
    return instance;
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
//已经注册成功后调用
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
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
@end
