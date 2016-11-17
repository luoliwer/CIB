//
//  CustomStatusBar.m
//  CIBSafeBrowser
//
//  Created by wangzw on 15/11/9.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "CustomStatusBar.h"

@implementation CustomStatusBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        self.backgroundColor = [UIColor  blackColor];
        
        _messageLabel = [[UILabel alloc] initWithFrame:self.frame];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:10.0f];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:_messageLabel];
    }
    return self;
}

- (void)showStatusMessage:(NSString *)message
{
    self.hidden = NO;
    self.alpha = 1.0f;
    _messageLabel.text = @"";
    
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){self.frame.origin,0,totalSize.height};
    [UIView animateWithDuration:0.0f animations:^{
        self.frame = (CGRect){self.frame.origin,totalSize};
    } completion:^(BOOL finished) {
        _messageLabel.text = message;
    }];
}
- (void)hide
{
    self.alpha = 1.0f;
    [UIView animateWithDuration:0.0f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _messageLabel.text = @"";
        self.hidden = YES;
    }];
}
@end
