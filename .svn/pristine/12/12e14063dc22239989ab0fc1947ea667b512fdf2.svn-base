//
//  SuperViewController.m
//  CIBSafeBrowser
//
//  Created by yanyue on 16/8/10.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "SuperViewController.h"
#import "AppDelegate.h"
#import "ActivationViewController.h"
#import "LoginViewController.h"
@interface SuperViewController ()

@end

@implementation SuperViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    __block SuperViewController* selfBlock = self;
    self.loginSucceededBlock=^(){
        [AppDelegate delegate].isLogin = YES;
        selfBlock.mainFromState=MainFromLoginSucc;
//        [FingerWorkManager clearFingerWork];
    };
}

-(void) viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate delegate];
    if(self.mainFromState==MainFromLoginSucc){
        self.mainFromState=MainFromDefault;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Setting" bundle:[NSBundle mainBundle]];
        ActivationViewController *activation = [story instantiateViewControllerWithIdentifier:@"activation"];
        __block ActivationViewController* activationBlock=activation;
        activation.activationSuccBlock=^(){
            self.mainFromState=MainFromActivationSucc;
             [activationBlock dismissViewControllerAnimated:YES completion:^{}];
        };
        activation.backBlock=^(){
            self.mainFromState=MainFromActivationBack;
        };
        [self presentViewController:activation animated:YES completion:nil];
         self.ifReturn=YES;
    }else if(self.mainFromState==MainFromActivationBack){
        self.mainFromState=MainFromDefault;
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        __block LoginViewController* loginVCBlock = loginVC;
        loginVC.loginSucceededBlock = ^(){
            self.loginSucceededBlock();
            [loginVCBlock dismissViewControllerAnimated:YES completion:nil];
        };
        [self presentViewController:loginVC animated:YES completion:^{
            loginVC.usernameTextField.userInteractionEnabled = YES;
        }];
        self.ifReturn=YES;
    }else if(self.mainFromState==MainFromActivationSucc){
        self.mainFromState=MainFromDefault;
        if(![FingerWorkManager isFingerWorkExisted]) {
            [[AppDelegate delegate] showLockViewController:LockViewTypeCreate
                                               onSucceeded:^(){
                                                   appDelegate.isLogin = YES;
                                                   appDelegate.isUnlock = YES;
                                               }
                                                  onFailed:nil
             ];
        }
         self.ifReturn=YES;
    }else if(self.mainFromState==MainFromLockSucc){
        self.mainFromState=MainFromDefault;
        [self checkIfSetLine];
         self.ifReturn=YES;
    }
}
-(void) checkIfSetLine{
    // 新开线程查询有么有设置过条心啊
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 向服务端查询缓存文件的版本信息
        id paramDic = @{@"userId":[NSString stringWithFormat:@"%@", [AppInfoManager getUserID]]};
        [CIBRequestOperationManager invokeAPI:@"gup" byMethod:@"POST" withParameters:paramDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            if ([responseCode isEqualToString:@"I00"]) {
                NSDictionary *responseDic = (NSDictionary *)responseInfo;
                NSString *resultCode = [responseDic objectForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"]) {
                    NSArray *resourceInfoList = [responseDic objectForKey:@"result"];
                    BOOL isSeted=NO;//是否设置过条线
                    for (NSDictionary* lineObj in resourceInfoList) {
                        int focus = [[lineObj objectForKey:@"focus"] intValue];
                        if(focus==1){
                            isSeted=YES;
                            break;
                        }
                    }
                    if(!isSeted){
                        [self performSegueWithIdentifier:@"setAuthorSegue" sender:resourceInfoList];
                    }
                }
            }
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            NSLog(@"查询是否设置过条线失败：%@",responseInfo);
        }];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
