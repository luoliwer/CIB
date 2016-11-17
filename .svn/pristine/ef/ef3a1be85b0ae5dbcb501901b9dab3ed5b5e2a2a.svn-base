//
//  FileHandleController.m
//  CIBSafeBrowser
//
//  Created by cibdev-macmini-1 on 16/8/9.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "FileHandleController.h"

@interface FileHandleController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation FileHandleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //config navigation top view
    [self initNavigationView];
}

- (void)initNavigationView
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    view.backgroundColor = [UIColor colorWithRed:0.0 green:118.0/255 blue:209.0/255 alpha:1.0];
    
    [self.view addSubview:view];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 40, 40);
    [backBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [view addSubview:backBtn];
    
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *title = [[UILabel alloc] init];
    title.frame = CGRectMake(40, 20, view.bounds.size.width - 80, 40);
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:18];
    title.textColor = [UIColor whiteColor];
    title.text = @"查看附件";
    [view addSubview:title];
    
    _webView = [[UIWebView alloc] init];
    _webView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    [self.view addSubview:_webView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadPdf:self.webView];
}

- (void)loadPdf:(UIWebView *)webView
{
    NSURL *url = [NSURL URLWithString:self.pdfPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];    
}

- (void)back:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
