//
//  ImageAlertView.m
//  CIBSafeBrowser
//
//  Created by luolihacker on 15/12/30.
//  Copyright © 2015年 cib. All rights reserved.
//

#import "ImageAlertView.h"

@implementation ImageAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)viewShowWithImage:(UIImage *)loadingImage message:(NSString *)message
{
    UIView *backgroud = [[UIView alloc] initWithFrame:self.frame];
    backgroud.backgroundColor = [UIColor blackColor];
    backgroud.alpha = 0.48;
    [self addSubview:backgroud];
    
    CGPoint center = backgroud.center;
    
    UIView *editView = [[UIView alloc] init];
    editView.backgroundColor = [UIColor whiteColor];
    editView.frame = CGRectMake(center.x-135, center.y-76, 270, 100);
    editView.layer.cornerRadius = 8.f;
    [self addSubview:editView];
    
    CGSize editViewSize = editView.frame.size;
    UIImageView *loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(editViewSize.width / 2 - 12.5, 20, 25, 25)];
    loadingImageView.image = loadingImage;
    [editView addSubview:loadingImageView];
    if ([message isEqualToString:@"请求失败"] || [message isEqualToString:@"证书已更换"] || [message isEqualToString:@"设置手势密码成功，正在进入主页..."]|| [message isEqualToString:@"用户名或密码错误!"]|| _failure) {
    }else{
        [self animation:loadingImageView];
    }
    //[message isEqualToString:@"似乎已断开与互联网的连接。"]
    if ([message isEqualToString:@"请求超时。"]) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, editViewSize.height-20-15, editViewSize.width - 16, 20)];
        messageLabel.text = message;
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [editView addSubview:messageLabel];
    }else{
        if (message.length >= 23) {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [messageLabel setNumberOfLines:0];
            [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
            NSString *string = message;
            messageLabel.font = [UIFont systemFontOfSize:15];
            messageLabel.text = string;
            CGSize size = CGSizeMake(editViewSize.width - 16, 2000);
            CGSize labelSize = [string sizeWithFont:messageLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
            messageLabel.frame = CGRectMake(8, editViewSize.height-20-15-5, labelSize.width, labelSize.height);
            [editView addSubview:messageLabel];
        }else{
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, editViewSize.height-20-15, editViewSize.width - 16, 20)];
            messageLabel.text = message;
            messageLabel.font = [UIFont systemFontOfSize:15];
            messageLabel.textColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1];
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [editView addSubview:messageLabel];
        }
    }
    if (self.autoHideAfterSeconds != 0) {
        [self performSelector:@selector(hidden) withObject:nil afterDelay:self.autoHideAfterSeconds];
    }
    
    if (_isHasBtn) {
        editViewSize = CGSizeMake(editViewSize.width, editViewSize.height+40+1);
        editView.frame = CGRectMake(center.x -130, center.y-100, editViewSize.width, editViewSize.height);
        
        //分割线
        UIView *hLine = [[UIView alloc] init];
        hLine.frame = CGRectMake(0, editViewSize.height-40, editViewSize.width, 1);
        hLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        [editView addSubview:hLine];
        
        UIView *vLine = [[UIView alloc] init];
        vLine.frame = CGRectMake(editViewSize.width/2, editViewSize.height-40, 1, 40);
        vLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        [editView addSubview:vLine];
        
        //按钮
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, editViewSize.height-40, editViewSize.width/2-0.5, 40);
        [cancelBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"下次再说" forState:UIControlStateNormal];
        cancelBtn.backgroundColor = [UIColor clearColor];
        cancelBtn.tag = 1;
        [cancelBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [editView addSubview:cancelBtn];
        
        UIButton *tryAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tryAgainBtn.frame = CGRectMake(editViewSize.width/2+0.5, editViewSize.height-40, editViewSize.width/2-0.5, 40);
        [tryAgainBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [tryAgainBtn setTitle:@"再试一次" forState:UIControlStateNormal];
        tryAgainBtn.backgroundColor = [UIColor clearColor];
        tryAgainBtn.tag = 2;
        [tryAgainBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [editView addSubview:tryAgainBtn];
    }
}

- (void)buttonPress:(UIButton *)button
{
    [self.delegate clickMyButtonIndex:button.tag];
    [self removeFromSuperview];
}

- (void)hidden
{
    [self removeFromSuperview];
}

//loadingImage动画
- (void)animation:(UIView *)imageView
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.duration = 1;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    [imageView.layer addAnimation:rotationAnimation forKey:@"animation"];
}



@end
