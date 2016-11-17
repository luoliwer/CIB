//
//  CommonNavViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 15/2/13.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "CommonNavViewController.h"

@interface CommonNavViewController ()

@end

@implementation CommonNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// 是否支持转屏
- (BOOL)shouldAutorotate {
    return YES;
}

// 支持的屏幕方向，此处可直接返回 UIInterfaceOrientationMask 类型，也可以返回多个 UIInterfaceOrientationMask 取或运算后的值
// 除浏览器界面外，手机只支持 UIInterfaceOrientationMaskPortrait，平板支持 UIInterfaceOrientationMaskAll
- (NSUInteger)supportedInterfaceOrientations {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        return UIInterfaceOrientationMaskAll;
    }
    else {  // iPhone&iPod
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
