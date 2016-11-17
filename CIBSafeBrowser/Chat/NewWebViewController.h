//
//  NewWebViewController.h
//  CIBSafeBrowser
//
//  Created by 陈宇劢 on 16/2/26.
//  Copyright © 2016年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewWebViewController : UIViewController

- (IBAction)back:(id)sender;

- (IBAction)openApp:(id)sender;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *appNo;

@end


