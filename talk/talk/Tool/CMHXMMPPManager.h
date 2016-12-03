//
//  CMHXMMPPManager.h
//  talk
//
//  Created by mac on 2016/11/30.
//  Copyright © 2016年 常明会. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMHXMMPPManager : NSObject

+ (instancetype)sharedManager;
//登录
- (void)loginWithJID:(XMPPJID *)jid andPassword:(NSString *)password;
//注册
- (void)registerWithJID:(XMPPJID *)jid andPassword:(NSString *)password;
@end
