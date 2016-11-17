//
//  MenuViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 15/2/12.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"

#import "MainViewController.h"
#import "AppsViewController.h"
#import "FilesViewController.h"
#import "SettingViewController.h"

#import "Config.h"

#import <UIKit/UIKit.h>

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *menuItemIcons;
    NSArray *menuItemNames;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    menuItemIcons = @[@"file", @"app", @"setting"];
    menuItemNames = @[@"本地", @"应用", @"设置"];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [menuItemIcons count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuPrototypeCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.icon.image = [UIImage imageNamed:menuItemIcons[indexPath.row]];
    cell.name.text = menuItemNames[indexPath.row];
    
    // 选中颜色
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = kUIColorLight;
    
    return cell;
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 选中后立即取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:  // 本地文档
        {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"File" bundle:[NSBundle mainBundle]];
                [self.sideView replaceContentViewControllerWithViewController:[story instantiateViewControllerWithIdentifier:@"file"]];
                [self.sideView setPanGestureControllEnable:NO];
        }
            break;
        case 1:  // 业务应用
        {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"App" bundle:[NSBundle mainBundle]];
                [self.sideView replaceContentViewControllerWithViewController:[story instantiateViewControllerWithIdentifier:@"app"]];
                [self.sideView setPanGestureControllEnable:NO];
        }
            break;
        case 2:  // 设置
        {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Setting" bundle:[NSBundle mainBundle]];
                [self.sideView replaceContentViewControllerWithViewController:[story instantiateViewControllerWithIdentifier:@"setting"]];
                [self.sideView setPanGestureControllEnable:NO];
        }

            break;
        default:
            break;
    }
}

#pragma mark - CIBSideViewControllerPresenting

- (void)sideViewControllerWillOpen:(CIBSideViewController *)sideViewController
{
    self.view.userInteractionEnabled = NO;
}

- (void)sideViewControllerDidOpen:(CIBSideViewController *)sideViewController
{
    self.view.userInteractionEnabled = YES;
}

- (void)sideViewControllerWillClose:(CIBSideViewController *)sideViewController
{
    self.view.userInteractionEnabled = NO;
}

- (void)sideViewControllerDidClose:(CIBSideViewController *)sideViewController
{
    self.view.userInteractionEnabled = YES;
}

@end
