//
//  LockView.h
//
//
//  Created by CIB-Mac mini on 14-12-31.
//  Copyright (c) 2014年 cib. All rights reserved.
//
//  田字形手势解锁控件

#import <UIKit/UIKit.h>
#import "LockConfig.h"

@protocol LockDelegate <NSObject>

@required
- (void)lockString:(NSString *)string;

@end

@interface LockView : UIView

@property (nonatomic, weak) id<LockDelegate> delegate;

- (void)showErrorCircles:(NSString *)string; // 设置错误的密码以高亮
- (void)clearColorAndSelectedButton; // 重置

@end
