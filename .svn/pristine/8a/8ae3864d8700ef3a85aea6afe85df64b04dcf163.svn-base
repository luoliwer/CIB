//
//  AboutViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/8.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "Config.h"

@interface AboutViewController ()

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
- (IBAction)backBtnPress:(id)sender;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置version信息
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    self.versionLabel.text = [NSString stringWithFormat:@"V%@", version];
    
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"V%@ Build:%@", version,build];
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (IBAction)backBtnPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
