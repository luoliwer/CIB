//
//  ImageAlertView.h
//  CIBSafeBrowser
//
//  Created by luolihacker on 15/12/30.
//  Copyright © 2015年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ImageAlertViewDelegate
- (void)clickMyButtonIndex:(NSInteger)buttonIndex;
@end

@interface ImageAlertView : UIView
@property (assign, nonatomic) BOOL isHasBtn;
@property (assign, nonatomic) BOOL failure;
@property (assign, nonatomic) float autoHideAfterSeconds;
@property (weak, nonatomic) id<ImageAlertViewDelegate>delegate;
- (void)viewShowWithImage:(UIImage *)loadingImage message:(NSString *)message;
@end





