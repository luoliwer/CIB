//
//  CIBUITextField.m
//  CIBSafeBrowser
//
//  Created by 陈宇劢 on 15/6/11.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "CIBUITextField.h"

@implementation CIBUITextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
