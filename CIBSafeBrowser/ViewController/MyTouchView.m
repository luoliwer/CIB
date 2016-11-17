//
//  MyTouchView.m
//  CIBSafeBrowser
//
//  Created by yanyue on 16/3/22.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "MyTouchView.h"

@implementation MyTouchView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
 
}
*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView* btn =[self viewWithTag:1001];
    if(btn){
        BOOL isContains = CGRectContainsPoint(btn.frame, point);
        if(isContains){
            return btn;
        }
    }
    return nil;
}
@end
