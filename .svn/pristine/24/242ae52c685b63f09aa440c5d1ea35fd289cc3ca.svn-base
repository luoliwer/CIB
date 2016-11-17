//
//  FilesViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/11.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "FilesViewController.h"

#import "MainViewController.h"
#import "FileCell.h"
#import "DownloadFile.h"
#import "AppDelegate.h"
#import "Config.h"

#import "CoreDataManager.h"
#import "MyUtils.h"

#import "GTMBase64.h"
#import "CustomWebViewController.h"
#define IS_iPad  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

@interface NSIndexPath (MyIndexPath)
-(NSComparisonResult)myCompare:(NSIndexPath *)index;
@end
@implementation NSIndexPath (MyIndexPath)
-(NSComparisonResult)myCompare:(NSIndexPath *)index{
    if(self.row>index.row){
        //顺序
        return NSOrderedAscending;
    }else{
        //逆序
        return NSOrderedDescending;
    }
}
@end

@interface FilesViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *fileList;
@property BOOL fileEdit; //是否编辑状态
@property NSMutableArray *cellIndexPathArray;
@property (strong, nonatomic) IBOutlet UITableView *fileTableView;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;

- (IBAction)backBtnPress:(id)sender;  // 响应左侧返回按钮
- (IBAction)editBtnPress:(id)sender;  // 响应右侧编辑按钮

@end

@implementation FilesViewController
@synthesize toolEditView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
    toolEditView = [[UIButton alloc] init];
    toolEditView.backgroundColor = kUIColorLight;
    if (screenHiegth == 736 || IS_iPad){
        toolEditView.imageEdgeInsets = UIEdgeInsetsMake(-20, 0, 0, -48);
        toolEditView.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0);
    }else if(screenHiegth == 667){
        toolEditView.imageEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, -48);
        toolEditView.titleEdgeInsets = UIEdgeInsetsMake(35, -30, 0, 0);
    }else if(screenHiegth == 568){
        toolEditView.imageEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, -63);
        toolEditView.titleEdgeInsets = UIEdgeInsetsMake(32, -17, 0, 0);
    }
    
    [toolEditView setImage:[UIImage imageNamed:@"btn_del"] forState:UIControlStateNormal];
    [toolEditView setTitle:@"删除文档" forState:UIControlStateNormal];
    toolEditView.titleLabel.font = [UIFont systemFontOfSize:14];
    toolEditView.titleLabel.textAlignment = NSTextAlignmentCenter;

    toolEditView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    toolEditView.translatesAutoresizingMaskIntoConstraints = NO;
    [toolEditView addTarget:self action:@selector(fileDeletBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toolEditView];
    // toolEditView的高度
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:toolEditView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0.0f];
    // toolEditView左侧与父视图对齐
    NSLayoutConstraint *toolEditViewLeftConstraint = [NSLayoutConstraint constraintWithItem:toolEditView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
    // toolEditView右侧与父视图对齐
    NSLayoutConstraint *toolEditViewRightConstraint = [NSLayoutConstraint constraintWithItem:toolEditView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    // toolEditView底部与父视图底部对齐
    NSLayoutConstraint *toolEditViewBottomConstraint = [NSLayoutConstraint constraintWithItem:toolEditView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];

//    heightConstraint.active = YES;
//    toolEditViewBottomConstraint.active = YES;
//    toolEditViewLeftConstraint.active = YES;
//    toolEditViewRightConstraint.active = YES;
    [self.view addConstraints:@[heightConstraint,toolEditViewLeftConstraint,toolEditViewRightConstraint,toolEditViewBottomConstraint]];
    toolEditView.hidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;  // 不显示顶部空白
    self.fileTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];  // 有cell时不显示多余的分隔线（项为0时失效）
    
    self.fileEdit = NO;

    [self loadData];

}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    // 如果没有，去掉分隔线
    if (self.fileList.count > 0) {
        self.fileTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    else {
        self.fileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return [self.fileList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FilePrototypeCell";
    FileCell *cell = (FileCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    DownloadFile *file = (DownloadFile *)self.fileList[indexPath.row];
    cell.fileNameLabel.text = file.fileName;
    
    //下载时间
    NSArray *array = [file.downloadTime componentsSeparatedByString:@" "];
    NSString *time = [[array objectAtIndex:0] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    cell.downloadTimeLabel.text = time;
    
    //文件图标
    cell.iconImage.image = [self fileIconImageWithType:file.mimeType];
    
    cell.isSelect = NO;
    [cell.cellButtonSelect setBackgroundImage:[UIImage imageNamed:@"btn_sel"] forState:UIControlStateNormal];
    //右侧选择图标是否显示
    if (!self.fileEdit) {
        cell.cellButtonSelect.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else{
        cell.cellButtonSelect.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 额外的属性，用于打开文件
    cell.file = file;
    
    //    FileCell *cellPtr = cell;
    //    cell.onOpenButtonPress = ^(){
    //        [self performSegueWithIdentifier:@"fileToWebSegue" sender:cellPtr.file];
    //    };
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DownloadFile *file = (DownloadFile *)self.fileList[indexPath.row];
        
        // 在列表中删除数据
        [self.fileList removeObjectAtIndex:indexPath.row];
        //因为间隔行背景色不同，所以直接重新加载[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.fileTableView reloadData];
        
        // 从数据库删除数据
        CoreDataManager *cdManager = [[CoreDataManager alloc] init];
        [cdManager deleteFileInfoByAlias:file.fileAlias];
        
        // 从文件系统删除数据
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [paths objectAtIndex:0];
        NSString *docPath = [documentDir stringByAppendingPathComponent:file.fileAlias];
        [[NSFileManager defaultManager] removeItemAtPath:docPath error:nil];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

//// Override to support editing the delete confirmation button title.
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"删除";
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //file不是编辑状态才能打开
    if (!self.fileEdit) {
        // 选中后立即取消选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        DownloadFile *file = (DownloadFile *)self.fileList[indexPath.row];
        
        [MyUtils openFile:file];
    }
    //编辑状态，选择
    else
    {
        FileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell.isSelect) {
            cell.isSelect = YES;
            [cell.cellButtonSelect setBackgroundImage:[UIImage imageNamed:@"btn_sel_c"] forState:UIControlStateNormal];
            [self.cellIndexPathArray addObject:indexPath];
        }
        else
        {
            cell.isSelect = NO;
            [cell.cellButtonSelect setBackgroundImage:[UIImage imageNamed:@"btn_sel"] forState:UIControlStateNormal];
            [self.cellIndexPathArray removeObject:indexPath];
        }
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使分隔线顶到最左边
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - 响应按钮

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

//响应文件删除按钮
- (void)fileDeletBtnPress {
    
//    toolEditView.hidden = YES;
    NSArray *deleCellArray = [self.cellIndexPathArray sortedArrayUsingSelector:@selector(myCompare:)];
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    for (NSIndexPath *indexPath in deleCellArray ) {
        // 从数据库删除数据
        DownloadFile *file = [self.fileList objectAtIndex:indexPath.row];
        [cdManager deleteFileInfoByAlias:file.fileAlias];
        
        // 从文件系统删除数据
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [paths objectAtIndex:0];
        NSString *docPath = [documentDir stringByAppendingPathComponent:file.fileAlias];
        [[NSFileManager defaultManager] removeItemAtPath:docPath error:nil];
        
        //数组中删除
        [self.fileList removeObjectAtIndex:indexPath.row];
    }
    //表格删除行
    [self.fileTableView deleteRowsAtIndexPaths:deleCellArray withRowAnimation:UITableViewRowAnimationMiddle];
    [self.fileTableView reloadData];
    [self.cellIndexPathArray removeAllObjects];
}

// 响应左侧返回按钮
- (IBAction)backBtnPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// 响应右侧编辑按钮
- (IBAction)editBtnPress:(id)sender {
    if ([self.editBtn.titleLabel.text isEqualToString:@"编辑"]) {
        self.fileEdit = YES;

        toolEditView.hidden = NO;
        self.cellIndexPathArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self.editBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        [NSLayoutConstraint constraintWithItem:self.fileTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-90.f];
        [self.fileTableView reloadData];
    }
    if ([self.editBtn.titleLabel.text isEqualToString:@"取消"]) {
        [self.cellIndexPathArray removeAllObjects];
        self.fileEdit = NO;
        toolEditView.hidden = YES;

        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        
        [NSLayoutConstraint constraintWithItem:self.fileTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f];
        [self.fileTableView reloadData];
    }

}

- (void)loadData {
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    NSPredicate *statusPredicate = [NSPredicate predicateWithFormat:@"downloadStatus = %d",(int)FileDownloaded];

    

    self.fileList =  [[NSMutableArray alloc]initWithArray:[[cdManager getFileList]filteredArrayUsingPredicate:statusPredicate]];
    if (self.fileList == nil) {
        self.fileList = [[NSMutableArray alloc] init];
    }
}
- (UIImage *)fileIconImageWithType:(NSString *)type
{
    UIImage *iconImage = nil;
    if ([type hasSuffix:@"excel"]) {
        iconImage = [UIImage imageNamed:@"ic_xlsx"];
    }
    else if ([type hasSuffix:@"word"])
    {
        iconImage = [UIImage imageNamed:@"ic_docx"];
    }
    else if ([type hasSuffix:@"powerpoint"])
    {
        iconImage = [UIImage imageNamed:@"ic_pptx"];
    }
    else
    {
        iconImage = [UIImage imageNamed:@"ic_pdf"];
    }
    return iconImage;
}


- (void)changeIamge:(UIControl *)control
{
    NSArray *array = [control subviews];
    UIImageView *imageView = nil;
    for (UIView *image in array) {
        if ([image isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)image;
        }
    }
    imageView.image = [UIImage imageNamed:@"btn_del_p"];
    [self performSelector:@selector(hideDeleteBtn:) withObject:control afterDelay:0.2];
}
- (void)hideDeleteBtn:(UIControl *)control{
    NSArray *array = [control subviews];
    UIImageView *imageView = nil;
    for (UIView *image in array) {
        if ([image isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)image;
        }
    }
    imageView.image = [UIImage imageNamed:@"btn_del.png"];

    self.editBtn.titleLabel.text = @"编辑";
}

@end
