//
//  TouchView.m
//  CIBSafeBrowser
//
//  Created by 陈宇劢 on 15/5/12.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView
@synthesize receiver;
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        return self.receiver;
    }
    return nil;
}
@end
