//
//  SetAuthorViewController.m
//  CIBSafeBrowser
//
//  Created by wangzw on 16/6/23.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "SetAuthorViewController.h"
#import "MyUtils.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "ImageAlertView.h"
#import "MainViewController.h"
#import "AppDelegate.h"
@interface SetAuthorViewController ()

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageLabelConstraintHeight;

@property (strong, nonatomic) IBOutlet UIButton *returnBtn;
@property (strong, nonatomic) IBOutlet UITableView *lineTableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableviewTopConstraint;
@property(assign,nonatomic) int selectRowIndex;
@property(assign,nonatomic) int defaultRowIndex;
@property(strong,nonatomic) NSIndexPath* selectedPath;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *okBtn;
@end

@implementation SetAuthorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.isMondify){
        self.returnBtn.hidden=NO;
        self.cancelBtn.hidden=NO;
        self.titleLabel.text=@"修改条线";
        self.messageLabel.hidden=YES;
        self.tableviewTopConstraint.active=NO;
        [self loadData];
    }
    self.selectRowIndex=-1;
    self.defaultRowIndex=-1;
//    self.lineTableView.backgroundColor=[UIColor yellowColor];
    
    //设置提示蚊子换行
    CGSize textSize = [self.messageLabel.text sizeWithAttributes:@{NSFontAttributeName:self.messageLabel.font}];
    NSInteger width = self.view.frame.size.width-24; //24 是 约束中左右 各12
    if(textSize.width>width){
        self.messageLabelConstraintHeight.constant=self.messageLabelConstraintHeight.constant*2;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClick:(id)sender {
    if(!self.selectedPath){
        [MyUtils showAlertWithTitle:@"请选择需要设置的条线" message:nil];
        return;
    }
        // 向服务端查询缓存文件的版本信息
    NSMutableDictionary* dic = [self.lineTypeArray objectAtIndex:self.selectedPath.row];
        id paramDic = @{
                        @"userId":[NSString stringWithFormat:@"%@", [AppInfoManager getUserID]],
                        @"preference": @[
                                            @{
                                               @"preferenceId":[dic objectForKey:@"preferenceId"],
                                               @"preferenceType":[dic objectForKey:@"preferenceType"],
                                               @"focus":[NSNumber numberWithInt:1]
                                            }
                                        ]
                        };
    // 弹出菊花
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"处理中..."];
    [self.view addSubview:alertView];
        [CIBRequestOperationManager invokeAPI:@"uup" byMethod:@"POST" withParameters:paramDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            [alertView removeFromSuperview];
            if ([responseCode isEqualToString:@"I00"]) {
                NSDictionary *responseDic = (NSDictionary *)responseInfo;
                NSString *resultCode = [responseDic objectForKey:@"resultCode"];
                NSString* result =[responseDic objectForKey:@"result"];
                if ([resultCode isEqualToString:@"0"]) {
                    if(self.isMondify){
                        [self.navigationController popViewControllerAnimated:YES];
                        //通知更新app 列表
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"setAuthorSucc" object:nil];
                    }else{
                        //设置状态为 手势密码反回
                        id rootController = [AppDelegate delegate].window.rootViewController;
                        if([rootController isKindOfClass:[MainViewController class]]){
                            ((MainViewController*)rootController).mainFromState=MainFromSetAuthorSucc;
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    
                }else{
                    [MyUtils showAlertWithTitle:result message:nil];
                }
            }else{
                [MyUtils showAlertWithTitle:responseInfo message:nil];
            }
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            [alertView removeFromSuperview];
            NSLog(@"设置条线失败");
        }];
    
}
- (IBAction)returnBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark---- tableViewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.lineTypeArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [[UITableViewCell alloc] init];
    static NSString *CellIdentifier = @"setAuthorCell";
    UITableViewCell *cell = [self.lineTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary* lineObj = self.lineTypeArray[indexPath.row];
    
    UIImageView* img =[cell.contentView viewWithTag:2000];
    img.image=[UIImage imageNamed:@"unselected"];
    if(self.selectRowIndex!=-1 && indexPath.row==self.selectRowIndex){
        img.image=[UIImage imageNamed:@"selected"];
        self.selectedPath=indexPath;
    }else if(self.selectedPath && self.selectedPath.row==indexPath.row){
        img.image=[UIImage imageNamed:@"selected"];
    }
    
    //设置条线名
    UILabel* lineName = (UILabel*)[cell.contentView viewWithTag:1000];
    lineName.text=[lineObj objectForKey:@"preferenceValue"];
    // 设置最后一条分割线隐藏
    [cell.contentView viewWithTag:3000].hidden=NO;
    if(indexPath.row==[self.lineTypeArray count]-1){
        [cell.contentView viewWithTag:3000].hidden=YES;
    }
    return  cell;
}
#pragma mark-- tableDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectedPath){
        UITableViewCell* unSelectCell = [tableView cellForRowAtIndexPath:self.selectedPath];
        ((UIImageView*)[unSelectCell.contentView viewWithTag:2000]).image=[UIImage imageNamed:@"unselected"];
    }
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView* img = [cell.contentView viewWithTag:2000];
    img.image=[UIImage imageNamed:@"selected"];
    self.selectedPath=indexPath;
    self.selectRowIndex=-1;
    NSLog(@"%@",self.lineTypeArray);
    
    if(indexPath.row==self.defaultRowIndex){
        self.okBtn.backgroundColor=[UIColor grayColor];
        self.okBtn.userInteractionEnabled=NO;
    }else{
        self.okBtn.backgroundColor=[UIColor colorWithRed:18/255.0 green:119.0/255.0 blue:211/255.0 alpha:1.0];
        self.okBtn.userInteractionEnabled=YES;
    }
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.isMondify){
        
        
    }
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void) loadData{
    // 新开线程查询有么有设置过条心啊
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 向服务端查询缓存文件的版本信息
        id paramDic = @{@"userId":[NSString stringWithFormat:@"%@", [AppInfoManager getUserID]]};
        // 弹出菊花
        ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
        alertView.isHasBtn = NO;
        [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"加载中..."];
        [self.view addSubview:alertView];
        [CIBRequestOperationManager invokeAPI:@"gup" byMethod:@"POST" withParameters:paramDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            [alertView removeFromSuperview];
            if ([responseCode isEqualToString:@"I00"]) {
                NSDictionary *responseDic = (NSDictionary *)responseInfo;
                NSString *resultCode = [responseDic objectForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"]) {
                    self.lineTypeArray=[responseDic objectForKey:@"result"];
                    int i=0;
                    for(NSDictionary* dic in self.lineTypeArray){
                        int focus =  [[dic objectForKey:@"focus"] intValue];
                        if(focus==1){
                            self.selectRowIndex=i;
                            self.defaultRowIndex=i;
                            self.okBtn.backgroundColor=[UIColor grayColor];
                            self.okBtn.userInteractionEnabled=NO;
                            break;
                        }
                        i++;
                    }
                    [self.lineTableView reloadData];
                }
            }
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            [alertView removeFromSuperview];
            NSLog(@"获取条线数据失败：%@",responseInfo);
        }];
//    });
}
@end
