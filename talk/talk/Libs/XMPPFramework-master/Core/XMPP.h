// 
// Core classes  -- 核心库
// 
// Jabber ID--身份证 username@domain/resource-->full
//           username@domain --->bare
// zhangsan@im.itheima.com/iOS

#import "XMPPJID.h"
#import "XMPPStream.h"
#import "XMPPElement.h"
#import "XMPPIQ.h"
#import "XMPPMessage.h"
#import "XMPPPresence.h"
#import "XMPPModule.h"

// 
// Authentication -- 授权
// 

#import "XMPPSASLAuthentication.h"
#import "XMPPCustomBinding.h"
#import "XMPPDigestMD5Authentication.h"
#import "XMPPSCRAMSHA1Authentication.h"
#import "XMPPPlainAuthentication.h"
#import "XMPPXFacebookPlatformAuthentication.h"
#import "XMPPAnonymousAuthentication.h"
#import "XMPPDeprecatedPlainAuthentication.h"
#import "XMPPDeprecatedDigestAuthentication.h"

// 
// Categories
// 

#import "NSXMLElement+XMPP.h"
