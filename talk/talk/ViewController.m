//
//  ViewController.m
//  talk
//
//  Created by mac on 2016/11/30.
//  Copyright © 2016年 常明会. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[CMHXMMPPManager sharedManager] loginWithJID:[XMPPJID jidWithUser:@"Jim" domain:@"changminghuidemacbook-pro.local" resource:@"ios"] andPassword:@"123456"];
//    [[CMHXMMPPManager sharedManager] registerWithJID:[XMPPJID jidWithUser:@"Alex" domain:@"changminghuidemacbook-pro.local" resource:@"ios"] andPassword:@"123456"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
