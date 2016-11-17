//
//  LoginViewController.h
//  CIBSafeBrowser
//  登陆界面控制器类
//  Created by CIB-Mac mini on 14-12-31.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYKeyboard.h"

@interface LoginViewController : UIViewController
{
    NSMutableArray*dataArray;
    HYKeyboard*keyboard;
    NSArray*contents;
    NSString*inputText;
    BOOL usesafeKeyboard;
    
}
@property (nonatomic, copy) void(^loginSucceededBlock)();
@property (nonatomic, copy) void(^loginFailedBlock)();

@property (retain, nonatomic) IBOutlet UITextField *usernameTextField;
//@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
//@property (strong, nonatomic) IBOutlet UIView *passwordView;
@property (strong, nonatomic) IBOutlet UIView *userNameView;

@property (nonatomic) BOOL dismissWhenSucceeded;  // 登录成功后是否主动消失，默认消失

- (IBAction)onLoginButtonPress:(id)sender;

@end
