//
//  PageView.m
//  CIBSafeBrowser
//
//  Created by cib on 15/3/18.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "PageView.h"

@implementation PageView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"PageView" owner:self options:nil] lastObject];
        [self setFrame:frame];
        
        self.snapshotImg = (UIImageView *)[self viewWithTag:2001];
        self.closeBtn = (KUIButton *)[self viewWithTag:2003];
        self.closeBtnTouch = (TouchView *)[self viewWithTag:2005];
        self.closeBtnTouch.receiver = self.closeBtn;
        
        self.iconImg=(UIImageView*)[self viewWithTag:3001];
        self.appNameLabel=(UILabel*)[self viewWithTag:3002];
        
        //增加阴影
        self.iconImg.layer.shadowColor=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0].CGColor;
        self.iconImg.layer.shadowOffset=CGSizeMake(0, 0);
        self.iconImg.layer.shadowOpacity=0.3;
        self.iconImg.layer.shadowRadius=14.0;

        self.snapshotImg.layer.cornerRadius=4.0;
        self.snapshotImg.layer.masksToBounds = YES;
        [self bringSubviewToFront:self.closeBtnTouch];
        
        self.iconImg.hidden=YES;
    }
    return self;
}

@end
