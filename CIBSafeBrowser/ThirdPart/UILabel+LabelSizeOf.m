//
//  UILabel+LabelSizeOf.m
//  CIBSafeBrowser
//
//  Created by yanyue on 16/1/29.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "UILabel+LabelSizeOf.h"

@implementation UILabel(LabelSizeOf)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(void) resizeFrame:(UILabel*) label withParent:(UIView*)view{
    [label sizeToFit];
    CGRect labelRect = label.frame;
    label.frame=CGRectMake(view.frame.size.width/2-labelRect.size.width/2, view.frame.size.height/2-labelRect.size.height/2, labelRect.size.width, labelRect.size.height);
}

@end
