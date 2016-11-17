//
//  LockViewController.h
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-12-31.
//  Copyright (c) 2014年 cib. All rights reserved.
//
//
//  解锁控件头文件，使用时包含它即可

#import <UIKit/UIKit.h>
#import "LockView.h"
#import "LockConfig.h"

#import <CIBBaseSDK/CIBBaseSDK.h>


// 进入此界面时的不同目的
typedef enum {
    LockViewTypeCheck,  // 检查手势密码
    LockViewTypeCreate, // 创建手势密码
    LockViewTypeModify, // 修改
    LockViewTypeClean,  // 清除
} LockViewType;

@interface LockViewController : UIViewController <LockDelegate>


@property (nonatomic) LockViewType nLockViewType; // 此窗口的类型
@property (nonatomic, strong) NSString *user; // 当前用户
@property (nonatomic, copy) void(^succeededBlock)();  // 操作成功时的回调
@property (nonatomic, copy) void(^failBlock)();  // 操作失败（Check、Modify、Clean时多次输入原手势失败）时的回调(注：操作失败时已自动清除原有手势)
@property (nonatomic, assign) BOOL isModify; //判断是否是修改密码

@property (strong, nonatomic) IBOutlet UIView *superViewOfPortrait;
- (id)initWithType:(LockViewType)type; // 直接指定方式打开
- (id)initWithType:(LockViewType)type user:(NSString *)user; // 直接指定方式打开，且当前用户为user

@end
