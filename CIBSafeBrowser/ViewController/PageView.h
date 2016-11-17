//
//  PageView.h
//  CIBSafeBrowser
//
//  Created by cib on 15/3/18.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KUIButton.h"
#import "TouchView.h"

@interface PageView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *snapshotImg;
@property (strong, nonatomic) IBOutlet KUIButton *closeBtn;
@property (strong, nonatomic) IBOutlet TouchView *closeBtnTouch;

@property (strong, nonatomic) IBOutlet UIImageView *iconImg;
@property (strong, nonatomic) IBOutlet UILabel *appNameLabel;

//@property (strong, nonatomic) NSString *iconUrl;
//@property (strong, nonatomic) NSString *appName;

@end
