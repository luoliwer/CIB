//
//  SuperViewController.h
//  CIBSafeBrowser
//
//  Created by yanyue on 16/8/10.
//  Copyright © 2016年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, MainFromState) {
    MainFromDefault,//初始状态
    MainFromLoginSucc,//登录成功
    MainFromActivationBack,//短信验证界面点击返回
    MainFromActivationSucc,//短信验证界面面激活成功
    MainFromSetAuthorSucc,//设置条线成功返回
    MainFromLockSucc//设置手势密码或解锁手势密码
};
@interface SuperViewController : UIViewController

    @property(nonatomic, assign) MainFromState mainFromState;
    @property(nonatomic, assign) BOOL ifReturn;
    @property (nonatomic, copy) void(^loginSucceededBlock)();
@end
