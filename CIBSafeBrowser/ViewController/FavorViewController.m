//
//  FirstViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/4.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "FavorViewController.h"

#import "AppDelegate.h"
#import "AppProduct.h"
#import "AppCell.h"
#import "CustomWebViewController.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "SearchViewController.h"
#import "GlobleData.h"

#import "SecUtils.h"
#import "MyUtils.h"
#import "CoreDataManager.h"
#import "Config.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "MKNumberBadgeView.h"
#import "NewsPage.h"
#import "NewWebViewController.h"

#import "MyUtils.h"
#import "AppFavor.h"

#import <CIBBaseSDK/CIBBaseSDK.h>

#define IS_iPad  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

@interface FavorViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate>
{
    NSMutableArray *appDeletArray;
    float _imageScrollWidth;
    float _imageScrollCurrentpage;
    
    float _imageScrollHeight;
    NSMutableArray* scrollImgArray;
    NewsPage* newsPage;
    NSTimer* scrollTimer;}

@end

@implementation FavorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUnreadMessageBubble];
    _imageScrollWidth = self.view.frame.size.width;
    [self loadData];
    self.isEdit = NO;
    // 添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.favorCollectionView addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletApp) name:@"deletApp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editExit) name:@"editExit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUnreadMessageBubble) name:kUnreadMsgNumberUpdatedNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changMessageIcon) name:@"changMessageIcon" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changMessageIcon_enable) name:@"changMessageIcon_enable" object:nil];
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidAppear:(BOOL)animated
{
    
//    [self loadUnreadMessageBubble];
}
-(void) viewWillDisappear:(BOOL)animated{
    
}
// 旋转后的处理
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.favorCollectionView reloadData];
}


#pragma mark -- collection view data source

// item数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_appList count];
}

// 加载item
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FavorPrototypeCell";
    AppCell *cell = (AppCell *) [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.isSelected = NO;
    // 加载数据
    AppProduct *app = _appList[indexPath.row];
    if (app != (id)[NSNull null]) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage* image = [[manager imageCache] imageFromMemoryCacheForKey:app.appIconUrl];
        if (image) {
            cell.icon.image = image;
        }
        else {
            [cell.icon sd_setImageWithURL:[NSURL URLWithString:app.appIconUrl] placeholderImage:[UIImage imageNamed:@"defalutIcon"]];
        }
        if (self.isEdit) {
            cell.selecteImage.hidden = NO;
            if ([appDeletArray count] == 0) {
                cell.selecteImage.image = [UIImage imageNamed:@"unselected"];
            }
            else
            {
                for (NSIndexPath *selectedIndexPath in appDeletArray) {
                    //选中app图标
                    if (indexPath.row == selectedIndexPath.row) {
                        cell.selecteImage.image = [UIImage imageNamed:@"selected"];
                        break;
                    }
                    else
                    {
                        
                        cell.selecteImage.image = [UIImage imageNamed:@"unselected"];
                    }
                }
            }
        }
        else
            cell.selecteImage.hidden = YES;
        
        cell.name.text = app.appShowName;
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [UIColor colorWithRed:230.0f/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1].CGColor;
        // 检查此app是否有未读的推送消息
        int notiNo = [app.notiNo intValue];
        
        // 在app图标上标记
//        CGFloat width = 40.0f;
//        CGRect badgeViewFrame = CGRectMake(cell.frame.size.width - width, 0.0f, width, width);
//        MKNumberBadgeView *badgeView = [[MKNumberBadgeView alloc] initWithFrame:badgeViewFrame];
//        badgeView.shadow = NO;
//        badgeView.shine = NO;
//        badgeView.hideWhenZero = YES;
//        badgeView.value = notiNo;
        
//        NSArray *subviews = cell.contentView.subviews;
//        if (notiNo > 0) {
//            // 现在只标记一个小红点
//            UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width - 15, 5.0f, 10, 10)];
//            badgeView.layer.cornerRadius = 5;
//            badgeView.backgroundColor = [UIColor redColor];
//            badgeView.tag = 8000;
//            [cell.contentView addSubview:badgeView];
//        }
        // 此处cell显示有缓存bug。先检查一下消息推送数目是否大于0
        if (notiNo > 0) {
            // 检查一下cell里是否已经有badgeView
            NSArray *subViews = cell.contentView.subviews;
            BOOL isBadgeViewExisted = NO;
            for (UIView *sv in subViews) {
                if (sv.tag == 8000) {
                    isBadgeViewExisted = YES;
                    break;
                }
            }
            // 没有badgeView才生成添加
            if (!isBadgeViewExisted) {
                // 现在只标记一个小红点
                UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width - 15, 5.0f, 10, 10)];
                badgeView.layer.cornerRadius = 5;
                badgeView.backgroundColor = [UIColor redColor];
                badgeView.tag = 8000;
                [cell.contentView addSubview:badgeView];
            }
        }
        else {
            // 检查一下cell里是否已经有badgeView
            for (UIView *sv in cell.contentView.subviews) {
                // 有badgeView的话，就移除掉
                if (sv.tag == 8000) {
                    [sv removeFromSuperview];
                }
            }
        }
    }
    else {
        NSString *imageToLoad = @"ic_addApp";
        cell.icon.image = [UIImage imageNamed:imageToLoad];
        cell.name.text = @"添加应用";
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [UIColor colorWithRed:230.0f/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1].CGColor;
        cell.selecteImage.hidden = YES;
    }
    cell.selectIconConstraintWidth.constant=cell.selecteImage.image.size.width;
    cell.selectIconConstraintHeight.constant=cell.selecteImage.image.size.height;
    cell.name.font=[UIFont systemFontOfSize:15.0];
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader] && _header==nil)
    {
        _header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CollectionFootView" forIndexPath:indexPath];
        float ScroHigth = 0.0;
        float homeHiegth = 0.0;
        CGFloat recoverHiegth = 0.0;
        CGFloat spot4Rigth = 0.0;
        CGFloat spot4Top = 0.0;
        UIScrollView *scroll = [[UIScrollView alloc] init];
        UIImageView *homeImageView = [[UIImageView alloc] init];
//        scroll.backgroundColor = [UIColor blackColor];
        NSString *imageNamed = nil;
        NSString *imageNamedInfo = nil;
        CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if (IS_iPad) {
            imageNamed = @"banner_6+.png";
            imageNamedInfo = @"homebg_6+.png";
            ScroHigth = 1024 * (340.0 / 2) / 480 ;
            homeHiegth = 1024 * (230.0 / 2) / 480;
            recoverHiegth = 16 * (1024 / 736)+18;
            spot4Rigth = 228.0/2.66667/414 * (screenWidth);
            spot4Top = 216.0/(470.0/2) * ScroHigth;
        }
        else  if (screenHiegth == 480) {
            imageNamed = @"banner_4.png";
            imageNamedInfo = @"homebg_5、4S.png";
            ScroHigth = 340.0/2;
            homeHiegth = 230.0/2;
            recoverHiegth = 10;
            spot4Rigth = 134.0/2;
            spot4Top = 216.0/(470.0/2) * ScroHigth;
        }
        else if (screenHiegth == 568) {
            imageNamed = @"banner_5.png";
            imageNamedInfo = @"homebg_5、4S.png";
            ScroHigth = 400.0/2;
            homeHiegth = 230.0/2;
            recoverHiegth = 10;
            spot4Rigth = 134.0/2;
            spot4Top = 216.0/(470.0/2) * ScroHigth;
        }
        else if (screenHiegth == 667){
            imageNamed = @"banner_6.png";
            imageNamedInfo = @"homebg_6.png";
            ScroHigth = 470.0/2;
            homeHiegth = 230.0/2;
            recoverHiegth = 10;
            spot4Rigth = 132.0/2;
            spot4Top = 216;
        }
        else if (screenHiegth == 736)
        {
            imageNamed = @"banner_6+.png";
            imageNamedInfo = @"homebg_6+.png";
            ScroHigth = 778.0/3;
            homeHiegth = 380.0/3;
            recoverHiegth = 16;
            spot4Rigth = 228.0/3;
            spot4Top = 216.0/(470.0/2) * ScroHigth;
        }
        //655/340 重网络上获取到图片的宽高比
        if(!IS_iPad){
            ScroHigth=[[AppDelegate delegate] getBannerHeight:_imageScrollWidth];
        }
        
        
        _header.advertismentView.frame = CGRectMake(0, 0, _imageScrollWidth, ScroHigth);
        
        scroll.frame = CGRectMake(0, 0, _imageScrollWidth, ScroHigth);
        scroll.pagingEnabled = YES;
        scroll.bounces = YES; //弹簧效果
//        scroll.contentSize = CGSizeMake(_imageScrollWidth * 6, ScroHigth);
        scroll.contentOffset = CGPointMake(_imageScrollWidth, 0);
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.delegate =self;
        [_header.advertismentView addSubview:scroll];
        [_header.advertismentView sendSubviewToBack:scroll];
        _header.imageScrollView = scroll;
        
        [_header addConstraint:[NSLayoutConstraint constraintWithItem:_header.infoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_header attribute:NSLayoutAttributeTop multiplier:1 constant:ScroHigth - recoverHiegth]];
        [_header addConstraint:[NSLayoutConstraint constraintWithItem:_header.infoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_header attribute:NSLayoutAttributeHeight multiplier:0 constant:homeHiegth]];
        
        //添加 背景
        _header.scrollViewBackground=[[UIImageView alloc] initWithFrame:scroll.frame];
        _header.scrollViewBackground.image=[UIImage imageNamed:@"banner_default"];
        [_header.advertismentView addSubview:_header.scrollViewBackground];
        [_header.advertismentView bringSubviewToFront:_header.scrollViewBackground];
        
        homeImageView.image = [UIImage imageNamed:imageNamedInfo];
        homeImageView.frame = CGRectMake(0, 0, _imageScrollWidth, homeHiegth);
        [_header.infoView addSubview:homeImageView];
        [_header.infoView sendSubviewToBack:homeImageView];
        //消息气泡
        NSArray *appListArray = [[NSMutableArray alloc]initWithArray:[[AppDelegate delegate] getAppProductList]];
        
        if (appListArray == nil) {
            appListArray = [[NSMutableArray alloc] init];
        }
        AppProduct *app = nil;
        for (AppProduct *theApp in appListArray) {
            if ([theApp.appShowName isEqualToString:@"信息"]) {
                app = theApp;
                break;
            }
        }
        _imageScrollHeight=ScroHigth;
        //读取首页展示图片
        [self loadScrollImg];
    }
    return _header;
}
- (void)goToNewsDetail:(UITapGestureRecognizer *)tap{
    NSInteger contentId =tap.view.tag;
    NewWebViewController *newWebVC = [[NewWebViewController alloc] init];
    
    NSString *appName = @"news"; // 新闻
    CoreDataManager *manager = [[CoreDataManager alloc] init];
    AppProduct *app = [manager getAppProductByAppName:appName];
    NSString *appNo = [app.appNo stringValue];
    newWebVC.appNo = appNo;
    NSString *appIndexUrl = app.appIndexUrl;
    // 拼接新闻的分享界面url
    newWebVC.url = [NSString stringWithFormat:@"%@share.html?newsId=%ld",appIndexUrl,contentId];
    newWebVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.parentViewController presentViewController:newWebVC animated:YES completion:nil];
    
}
-(void) refreshScrollImg{
    if([scrollImgArray count]>0){
        [_header.scrollViewBackground removeFromSuperview];
        NSInteger imgCount = [scrollImgArray count]+2;
        _header.imageScrollView.contentSize = CGSizeMake(_imageScrollWidth *imgCount , _imageScrollHeight);
        for(int index=0;index<imgCount;index++){
            NSMutableDictionary* imgObj = nil;
           
            if(index==0){
                imgObj=[scrollImgArray objectAtIndex:[scrollImgArray count]-1];
            }else if(index==imgCount-1){
                imgObj=[scrollImgArray objectAtIndex:0];
            }else{
                imgObj=[scrollImgArray objectAtIndex:index-1];
            }
             NSString *iUrl =[imgObj objectForKey:@"imgurl"];
            NSString *title =[imgObj objectForKey:@"title"];
            // 判断一下基础的url地址，据此来决定是否将内网地址替换为外网
            NSString *basicUrl = [URLAddressManager getBasicURLAddress];
            
            if ([basicUrl rangeOfString:@"220.250.30.210"].location == NSNotFound) { // 测试环境内网或生产环境
//                iUrl = [iUrl stringByReplacingOccurrencesOfString:@"220.250.30.210:8050" withString:@"168.3.23.207:7050"];
                
                 iUrl = [iUrl stringByReplacingOccurrencesOfString:@"https://168.3.23.207:7050" withString:@"http://168.7.61.180:7201"];
            }
            else { // 测试环境外网
                iUrl = [iUrl stringByReplacingOccurrencesOfString:@"168.3.23.207:7050" withString:@"220.250.30.210:8050"];
            }
            
            
            NSInteger contentId=[[imgObj objectForKey:@"contentid"] integerValue];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_imageScrollWidth * index, 0, _imageScrollWidth, _imageScrollHeight)];
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_imageScrollWidth * index, 0,665.0f, 340.0f)];
            imageView.tag=contentId;
            imageView.backgroundColor = [UIColor whiteColor];
            NSString* url = [iUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToNewsDetail:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tap];
            [_header.imageScrollView addSubview:imageView];
            
            //渐变背景
            UIImage *bannerBgImg = [UIImage imageNamed:@"banner_bg"];//banner_bg
            UIImageView* imv = [[UIImageView alloc] initWithImage:bannerBgImg];
//            UIColor *color = [[UIColor alloc] initWithPatternImage:bannerBgImg];
            UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0,imageView.frame.size.height-80, imageView.frame.size.width, 80)];
//            [bannerView setBackgroundColor:color];
            imv.frame=CGRectMake(0, 0, bannerView.frame.size.width, bannerView.frame.size.height);
//            imv.backgroundColor=[UIColor yellowColor];
            [bannerView addSubview:imv];
            [imageView addSubview:bannerView];
            
            
            //标题
            CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]}];
            UILabel *imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, imageView.frame.size.height-textSize.height-25, imageView.frame.size.width-40, textSize.height)];
            imgLabel.text=title;
            imgLabel.font=[UIFont systemFontOfSize:16.0];
//            imgLabel.backgroundColor=[UIColor yellowColor];
            imgLabel.textColor=[UIColor whiteColor];
            [imageView addSubview:imgLabel];
        }
        if(newsPage==nil){
            newsPage = [[NewsPage alloc]initWithFrame:CGRectMake(0,0, 0, 0)];
            newsPage.pattern = scrollImgArray.count;
            newsPage.backgroundColor=[UIColor clearColor];
            [self performSelector:@selector(addPageControl) withObject:nil afterDelay:0.1f];
        }
        
        if(scrollTimer==nil){
            dispatch_async(dispatch_get_main_queue(), ^{
               scrollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(autoChangeImg) userInfo:nil repeats:YES];
            });
        }
    }
}
-(void) addPageControl{
    [_header.advertismentView addSubview:newsPage];
    newsPage.translatesAutoresizingMaskIntoConstraints=NO;
    
    //宽
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:newsPage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:14*scrollImgArray.count];
//    widthConstraint.active=YES;
    [newsPage addConstraint:widthConstraint];
    //高
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:newsPage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:20.0f];
//    heightConstraint.active=YES;
    [newsPage addConstraint:heightConstraint];
    //右边距离边缘1/6
    CGFloat rightF =[[UIScreen mainScreen] bounds].size.width/7;
    NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:_header.advertismentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:newsPage attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:rightF];
    [_header.advertismentView addConstraint:leftConstraint];
//    leftConstraint.active=YES;
    
    //下边与父容器对其
    NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:_header.imageScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:newsPage attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    [_header.advertismentView addConstraint:bottomConstraint];
//    bottomConstraint.active=YES;
}
-(void) autoChangeImg{
        [_header.imageScrollView setContentOffset:CGPointMake(_imageScrollWidth*_imageScrollCurrentpage, 0) animated:YES];
        if(_imageScrollCurrentpage>[scrollImgArray count] || _imageScrollCurrentpage<1){
            _imageScrollCurrentpage=1;
            [self performSelector:@selector(changeOffset) withObject:nil afterDelay:2.0];
        }
        [newsPage changePage:_imageScrollCurrentpage];
        _imageScrollCurrentpage++;
}
-(void) changeOffset{
    [_header.imageScrollView setContentOffset:CGPointMake(_imageScrollWidth * 1, 0) animated:NO];
}
-(void) loadScrollImg{
    scrollImgArray= [NSMutableArray array];
    NSString* responseInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewsImageStr"];
    if (responseInfo) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[responseInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *resultCode = [responseDic objectForKey:@"resultCode"];
        if ([resultCode isEqualToString:@"0"]) {
            scrollImgArray = [responseDic objectForKey:@"pictures"];
            if([scrollImgArray count]>0){
                [self refreshScrollImg];
            }
        }
    }
    // 线程完成时的操作
    dispatch_async(dispatch_get_main_queue(), ^{
        // 请求成功的回调函数
        void(^succeededBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
            if ([responseCode isEqualToString:@"I00"]) {
                //                NSDictionary *responseDic = (NSDictionary *)responseInfo;
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[responseInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSString *resultCode = [responseDic objectForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"]) {
                    scrollImgArray = [responseDic objectForKey:@"pictures"];
                    [[NSUserDefaults standardUserDefaults] setObject:responseInfo forKey:@"NewsImageStr"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self refreshScrollImg];
                    
                }
            }
        };
        
        // 请求失败的回调函数
        void(^failedBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
            NSLog(@"error111:%@",responseInfo);
            if(_header.scrollViewBackground){
                _header.scrollViewBackground.image=[UIImage imageNamed:@"banner_fail"];
            }
        };
        
        @try {
            [CIBRequestOperationManager invokeAPI:@"cipgfp"
                                         byMethod:@"POST"
                                   withParameters:nil
                               onRequestSucceeded:succeededBlock
                                  onRequestFailed:failedBlock];
        }
        @catch (NSException *exception) {
            [MyUtils showAlertWithTitle:exception.description message:nil];
        }
        
    });
    
}

#pragma mark -- UICollectionViewDelegate
/*  点击事件的处理顺序如下：
    手指按下
    shouldHighlightItemAtIndexPath (如果返回YES则向下执行，否则执行到这里为止)
    didHighlightItemAtIndexPath (高亮)
    手指松开
    didUnhighlightItemAtIndexPath (取消高亮)
    shouldSelectItemAtIndexPath (如果返回YES则向下执行，否则执行到这里为止)
    didSelectItemAtIndexPath (执行选择事件)
 */
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // item背景颜色
    AppCell *cell = (AppCell *) [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    AppCell *cell = (AppCell *) [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isEdit) {
        return YES;
    }
    else if (indexPath.item == ([_appList count] - 1))
    {
        return NO;
    }
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //编辑状态下改变选中图标
    if (self.isEdit) {
        if (indexPath.item < ([_appList count] - 1)) {
            AppCell *cell = (AppCell *)[collectionView cellForItemAtIndexPath:indexPath];
            
            if (cell.isSelected) {
                cell.isSelected = NO;
                cell.selecteImage.image = [UIImage imageNamed:@"unselected"];
                [appDeletArray removeObject:indexPath];
                
            }
            else
            {
                cell.isSelected = YES;
                cell.selecteImage.image = [UIImage imageNamed:@"selected"];
                [appDeletArray addObject:indexPath];
            }

        }
        else
        {
            AppCell *cell = (AppCell *)[collectionView cellForItemAtIndexPath:indexPath];
            cell.isSelected = NO;
            cell.selecteImage.hidden = YES;
        }
        
    }
    //非编辑状态，打开app
    else{
        AppProduct *app = _appList[indexPath.row];
        if (app == (id)[NSNull null]) {
//            [AppDelegate delegate].FavorsLastSortIndex=-1;
//            if([_appList count]>1){
//                AppProduct *lasetApp =[_appList objectAtIndex:[_appList count]-2];
//                [AppDelegate delegate].FavorsLastSortIndex=lasetApp.sortIndex;
//            }
            [self.parentViewController performSegueWithIdentifier:@"mainToAddSegue" sender:nil];
        }
        else {
            if ([app.notiNo intValue] > 0) {
                //去除app图标上的推送消息标记，更新数据库中的未读消息数目
                app.notiNo = [NSNumber numberWithInt:0];
                CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                [cdManager updateAppInfo:app];
                
                // 更新明文临时变量为空 需要重新从数据库中读取
                [[AppDelegate delegate] setAppProductList:nil];
                
            }
            
            
            // 仅用于生产环境下连接测试环境的指标
#ifdef USING_CREDITINQUIRY2
            if ([app.appShowName isEqualToString:@"个人征信"]) {
                app.appIndexUrl = @"http://139.219.136.213/CreditInquiry2/";
            }
#endif
            
            // 检查网络
            if (![MyUtils isNetworkAvailableInView:self.view]) {
                return;
            }
            
            NSString *appIndexUrl = app.appIndexUrl;
            [MyUtils openUrl:appIndexUrl ofApp:app];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    //返回YES允许其item移动
    if (indexPath.item == ([_appList count] - 1)) {
        return NO;
    }
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    //目标是没app的item不能移动
    if (destinationIndexPath.item == ([_appList count] - 1)) {
        return;
    }
    
    //改变UI
    AppProduct *app = [_appList objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [_appList removeObject:app];
    
    //将数据插入到资源数组中的目标位置上
    [_appList insertObject:app atIndex:destinationIndexPath.item ];
    
    //更换移动后所要删除的app
    if ([appDeletArray count] != 0) {
        for (NSIndexPath *theIndexPath in appDeletArray)
        {
            if (sourceIndexPath.row == theIndexPath.row) {
                [appDeletArray removeObject:sourceIndexPath];
                [appDeletArray addObject:destinationIndexPath];
                break;
            }
        }
    }
    
    //通知传递collection偏移量，改变containt的坐标
    CGPoint offset = collectionView.contentOffset;
    NSString *offsetY = [NSString stringWithFormat:@"%f",offset.y];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"moveItemContentOffset" object:offsetY];
    collectionView.contentOffset = CGPointMake(0, 0);
    
    //#######################
    //保存位置顺序
    NSInteger index1 =sourceIndexPath.item<destinationIndexPath.item ? sourceIndexPath.item:destinationIndexPath.item;
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    
    NSMutableArray* favorList = [cdManager getAppFavorList];
    AppFavor* sourceFavor = [MyUtils getFavorFromList:favorList withAppName:app.appName];
    
    //移动start 在favorList  中的位置
    [favorList removeObject:sourceFavor];
    //将数据插入到资源数组中的目标位置上
    [favorList insertObject:sourceFavor atIndex:destinationIndexPath.item];
    
    for(int i =(int)index1;i<[favorList count];i++){
        AppFavor* currFavor =(AppFavor*)[favorList objectAtIndex:i];
        //找到favor 的开始位置
        NSNumber* targetSortIndex=[NSNumber numberWithInt:0];
        if(i>0){
            int sortIntIndex=[((AppFavor*)[favorList objectAtIndex:i-1]).sortIndex intValue]+1;
            targetSortIndex=[NSNumber numberWithInt:sortIntIndex];
        }
        currFavor.sortIndex=targetSortIndex;
        [cdManager updateAppFavor:currFavor];
        
        AppProduct *currApp = [MyUtils getProductFromList:_appList withAppName:currFavor.appName];
        if(currApp){
            currApp.sortIndex=[currFavor.sortIndex intValue];
            [cdManager updateAppInfo:currApp];
        }
    }
}


#pragma mark --- UICollectionViewDelegateFlowLayout;
//item 的大小适配
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat width = size.width/3.0;
    return CGSizeMake(width, width);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
//每行 两个item之间间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat higth;
    CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
    float tempH=[[AppDelegate delegate] getBannerHeight:_imageScrollWidth];
    if (IS_iPad) {
        higth = 1024.0 * (778.0/3 + 380.0/3 - 16 + 7) / 736 - 50;
    }
    else if (screenHiegth == 480) {
        higth = tempH + 230.0/2 - 10 + 7;
       
    }
    else if (screenHiegth == 568) {
        higth = tempH + 230.0/2 - 10 + 7;
    }
    else if (screenHiegth == 667){
        higth = tempH + 230.0/2 - 10 + 7;
    }
    else if (screenHiegth == 736)
    {
        higth = tempH + 380.0/3 - 16 + 7;
    }
    return CGSizeMake(self.view.frame.size.width, higth);
}

- (IBAction)longPressGestureRecognized:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    CGPoint location = [longPress locationInView:self.favorCollectionView];
    NSIndexPath *indexPath = [self.favorCollectionView indexPathForItemAtPoint:location];
     NSLog(@"indexPath:%ld",(long)indexPath.item);
    
    if (self.isEdit) {
        UIGestureRecognizerState state = longPress.state;
        NSInteger itemCount = [self.favorCollectionView numberOfItemsInSection:0];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:(itemCount - 1) inSection:0];
       
        static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
        static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
        static NSIndexPath *originalIndexPath = nil; //
        
        switch (state) {
            case UIGestureRecognizerStateBegan: {
                if (indexPath) {
                    originalIndexPath = indexPath;
                    sourceIndexPath = indexPath;
                    
                    if ([sourceIndexPath isEqual:lastIndexPath]) {
                        return;
                    }
                    
                    //长按通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"longPressGestureRecognized" object:nil];
                    //开始拖动item，collection可滚动
                    self.favorCollectionView.scrollEnabled = YES;
                    
                    UICollectionViewCell *cell = [self.favorCollectionView cellForItemAtIndexPath:indexPath];
                    
                    // Take a snapshot of the selected row using helper method.
                    snapshot = [self customSnapshoFromView:cell];
                    
                    // Add the snapshot as subview, centered at cell's center...
                    __block CGPoint center = cell.center;
                    snapshot.center = center;
                    snapshot.alpha = 0.0;
                    [self.favorCollectionView addSubview:snapshot];
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        // Offset for gesture location.
                        center.y = location.y;
                        center.x = location.x;
                        snapshot.center = center;
                        snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                        snapshot.alpha = 0.98;
                        
                        // Fade out.
                        cell.alpha = 0.0;
                    } completion:nil];
                    //在路径上则开始移动该路径上的cell
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
                    {
                       [self.favorCollectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
                    }
                    
                }
                break;
            }
            case UIGestureRecognizerStateChanged: {
                
                
                CGPoint center = snapshot.center;
                center.y = location.y;
                center.x = location.x;
                snapshot.center = center;
                if ([sourceIndexPath isEqual:lastIndexPath] || indexPath.item == ([_appList count] - 1)) {
                    UICollectionViewCell *cell = [self.favorCollectionView cellForItemAtIndexPath:sourceIndexPath];
                    cell.alpha=0.0;
                    return;
                }
                
                //移动过程当中随时更新cell位置
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
                {
                    [self.favorCollectionView updateInteractiveMovementTargetPosition:location];
                }else{
                    if (sourceIndexPath && indexPath && ![indexPath isEqual:sourceIndexPath] && ![indexPath isEqual:lastIndexPath])
                    {
                        // ... move the rows.
                        [self.favorCollectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                        // ... and update source so it is in sync with UI changes.
                        sourceIndexPath = indexPath;
                        
                        // ... hide the cell at indexPath
                        UICollectionViewCell *cell = [self.favorCollectionView cellForItemAtIndexPath:indexPath];
                        [cell setHidden:YES];
                    }
                }
                
                break;
            }
            case UIGestureRecognizerStateEnded:
            {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 )
                {
                    UICollectionViewCell *cell = [self.favorCollectionView cellForItemAtIndexPath:indexPath];
//                    bool isContains =CGRectContainsPoint(cell.frame, location);
                    //移动到cell以外的区域 或最后一项
                    if (indexPath.item == ([_appList count] - 1) || indexPath==nil) {
                        [snapshot removeFromSuperview];
                        snapshot = nil;
                        //完成移动后，不可滚动
                        self.favorCollectionView.scrollEnabled = NO;
                        //移动结束后关闭cell移动
                        [self.favorCollectionView endInteractiveMovement];
                        return;
                    }
                    
                    // Clean up.
                    [UIView animateWithDuration:0.25 animations:^{
                        snapshot.center = cell.center;
                        snapshot.transform = CGAffineTransformIdentity;
                        snapshot.alpha = 0.0;
                        cell.alpha = 1.0;
                    } completion:^(BOOL finished) {
                        [snapshot removeFromSuperview];
                        snapshot = nil;
                        [cell setHidden:NO];
                        //完成移动后，不可滚动
                        self.favorCollectionView.scrollEnabled = NO;
                        //移动结束后关闭cell移动
                        [self.favorCollectionView endInteractiveMovement];
                        
                    }];
                    break;

                }
                else
                {
                    
                    self.favorCollectionView.scrollEnabled = NO;
                    if (sourceIndexPath && indexPath && ![indexPath isEqual:sourceIndexPath] && ![indexPath isEqual:lastIndexPath]) {
                        
                        // ... update data source.
                        [_appList exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                        
                        // ... move the rows.
                        [self.favorCollectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                        
                        // ... and update source so it is in sync with UI changes.
                        sourceIndexPath = indexPath;
                    }

                }
                
            }
                
            default: {
                if ([sourceIndexPath isEqual:lastIndexPath]) {
                    return;
                }
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
                {
                   [self.favorCollectionView cancelInteractiveMovement];
                    break;
                }
                else
                {
                    
                    if(originalIndexPath && sourceIndexPath && originalIndexPath!=sourceIndexPath){
                        [_appList exchangeObjectAtIndex:originalIndexPath.row withObjectAtIndex:sourceIndexPath.row];
                        NSInteger low = MIN(originalIndexPath.row, sourceIndexPath.row);
                        NSInteger high = MAX(originalIndexPath.row, sourceIndexPath.row);
                        for (NSInteger i = high; i > (low + 1); i --) {
                            [_appList exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
                        }
                        // update the favor timestamp
                        double previousAppfavorTimeStamp = 0.0;
                        double nextAppfavorTimeStamp = 0.0;
                        if (sourceIndexPath.row == 0) { // moved to the first item
                            AppProduct *nextApp = _appList[sourceIndexPath.row + 1];
                            nextAppfavorTimeStamp = [nextApp.favoriteTimeStamp doubleValue];
                        }
                        else if (sourceIndexPath.row == (itemCount - 2)) { // moved to the last item
                            AppProduct *previousApp = _appList[sourceIndexPath.row - 1];
                            previousAppfavorTimeStamp = [previousApp.favoriteTimeStamp doubleValue];
                        }
                        else {
                            AppProduct *nextApp = _appList[sourceIndexPath.row + 1];
                            nextAppfavorTimeStamp = [nextApp.favoriteTimeStamp doubleValue];
                            AppProduct *previousApp = _appList[sourceIndexPath.row + 1];
                            previousAppfavorTimeStamp = [previousApp.favoriteTimeStamp doubleValue];
                        }
                        NSNumber *favorTimeStamp = [NSNumber numberWithDouble:(previousAppfavorTimeStamp + nextAppfavorTimeStamp) / 2];
                        AppProduct *app = _appList[sourceIndexPath.row];
                        app.favoriteTimeStamp = favorTimeStamp;
                        CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                        [cdManager updateAppInfo:app];
                        [[AppDelegate delegate] setAppProductList:nil];
                     }
                    // Clean up.
                    AppCell *cell = (AppCell *)[self.favorCollectionView cellForItemAtIndexPath:sourceIndexPath];
                    [UIView animateWithDuration:0.25 animations:^{
                        
                        snapshot.center = cell.center;
                        snapshot.transform = CGAffineTransformIdentity;
                        snapshot.alpha = 0.0;
                        
                        // Undo the fade-out effect we did.
                        
                        cell.alpha = 1.0;
                        
                    } completion:^(BOOL finished) {
                        [snapshot removeFromSuperview];
                        snapshot = nil;
                        [cell setHidden:NO];
                        
                    }];
                    sourceIndexPath = nil;
                break;
                }
                
            }
        }
    }
    //首次触发长按手势，设置编辑状态
    else{
        //只有触摸app 才进入编辑状态
        if(indexPath==nil || (long)indexPath.item ==[_appList count] - 1){
            return;
        }
        //取消选种颜色
        AppCell *appCell = (AppCell *)[self.favorCollectionView cellForItemAtIndexPath:indexPath];
        appCell.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
        [self.favorCollectionView reloadData];
        //长按通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"longPressGestureRecognized" object:nil];
        self.isEdit = YES;
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat imageScrollWidth = self.view.frame.size.width;
     if (offset.x == imageScrollWidth * ([scrollImgArray count]+1)) {
        [scrollView setContentOffset:CGPointMake(imageScrollWidth * 1, 0) animated:NO];
    }
    if (offset.x == 0) {
        [scrollView setContentOffset:CGPointMake(imageScrollWidth * [scrollImgArray count], 0) animated:NO];
    }
    float offsetX = scrollView.contentOffset.x;
    
    _imageScrollCurrentpage = offsetX / imageScrollWidth;
//    [self setTintImage:_imageScrollCurrentpage];
    
    [newsPage changePage:_imageScrollCurrentpage];
}

- (void)spotBtnPress:(UIButton *)button
{
    _imageScrollCurrentpage = (int)button.tag;
//    [self setTintImage:_imageScrollCurrentpage];
    NSArray *subViews = [_header.advertismentView subviews];
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            [scroll setContentOffset:CGPointMake(_imageScrollWidth * _imageScrollCurrentpage, 0) animated:YES];
        }
    }
    
}
#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}


#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

#pragma mark -- custom

- (void)loadData {
    appDeletArray = [[NSMutableArray alloc] initWithCapacity:0];
    _appList = [[NSMutableArray alloc]initWithArray:[[AppDelegate delegate] getAppProductListFilter]];
    // 最后增加一个空对象代表新增键
    [_appList addObject:[NSNull null]];
}

// 重新加载收藏列表
- (void)reloadFavors {
    [self loadData];
    [self.favorCollectionView reloadData];
}
-(void) changMessageIcon{
    if(_header && _header.messageBtn){
        [_header.messageBtn setBackgroundImage:[UIImage imageNamed:@"btn_message_disnable"] forState:UIControlStateNormal];
    }
}
-(void) changMessageIcon_enable{
    if(_header && _header.messageBtn){
        [_header.messageBtn setBackgroundImage:[UIImage imageNamed:@"btn_message"] forState:UIControlStateNormal];
    }
}
//删除收藏列表中的app
- (void)deletApp
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    for (NSIndexPath *indexPath in appDeletArray) {
        AppProduct* app = (AppProduct*)[_appList objectAtIndex:indexPath.item];
        [array addObject:app];
        app.isFavorite=NO;//切换成未收藏
        [cdManager updateAppInfo:app];
        
        //删除收藏表
        [cdManager deleteAppFavor:app.appName];
    }
    [_appList removeObjectsInArray:array];
    AppProduct *app = [[AppProduct alloc] init];
    for (app in array) {
        app.isFavorite = NO;
    }
    [self updateAppInfo:array];
    [self.favorCollectionView deleteItemsAtIndexPaths:appDeletArray];
    [appDeletArray removeAllObjects];
    //删除app，通知Main中collection高度变化
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didDeletApp" object:nil];
    
    //刷新添加页面
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteApplication" object:nil];
    
}

- (void)updateAppInfo:(NSArray *)favAppList {
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    
    for (AppProduct *app in favAppList) {
        [cdManager updateAppInfo:app];
    }
    
    // 更新明文临时变量为空 需要重新从数据库中读取
    [[AppDelegate delegate] setAppProductList:nil];
}

- (void)editExit
{
    self.isEdit = NO;
    [self.favorCollectionView reloadData];
    [appDeletArray removeAllObjects];
}
- (NSMutableArray *)applistArray
{
    [self loadData];
    return _appList;
}
//消息气泡
- (void)loadUnreadMessageBubble
{
    NSString *unreadMsgCount = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfUnreadMsgNumber];
    for (UIView *view in self.view.subviews) {
        if (view.tag == 1000) {
            [view removeFromSuperview];
        }
    }
    if (unreadMsgCount.length == 0 || [unreadMsgCount isEqualToString:@"0"]) {
        return;
    }
    // 添加消息提醒气泡
    UIImageView *leftImg = [[UIImageView alloc] init];
    leftImg.image = [UIImage imageNamed:@"ic_xiaoxiqipao_left"];
    leftImg.backgroundColor = [UIColor clearColor];
    leftImg.tag = 1000;
    [self.view addSubview:leftImg];
    
    UIImageView *middleImg = [[UIImageView alloc] init];
    middleImg.image = [UIImage imageNamed:@"ic_xiaoxiqipao_middle"];
    middleImg.backgroundColor = [UIColor clearColor];
    middleImg.tag = 1000;
     [self.view addSubview:middleImg];
    
    UIImageView *rightImg = [[UIImageView alloc] init];
    rightImg.image = [UIImage imageNamed:@"ic_xiaoxiqipao_right"];
    rightImg.backgroundColor = [UIColor clearColor];
    rightImg.tag = 1000;
    [self.view addSubview:rightImg];
    
    UILabel *unreadMsgCountLabel = [[UILabel alloc] init];
    unreadMsgCountLabel.font = [UIFont systemFontOfSize:11];
    unreadMsgCountLabel.textAlignment = NSTextAlignmentCenter;
    unreadMsgCountLabel.text = unreadMsgCount;
    unreadMsgCountLabel.textColor = [UIColor whiteColor];
    unreadMsgCountLabel.tag = 1000;
    [self.view addSubview:unreadMsgCountLabel];
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (unreadMsgCount.length >= 1 && unreadMsgCount.length <= 2){
        if (height == 568) {
            leftImg.frame = CGRectMake(278, 226, 10, 20);
            middleImg.frame = CGRectMake(288, 226, 0, 20);
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 226, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(278, 226, 20, 20);
        }else if(height == 667){
            leftImg.frame = CGRectMake(323, 255, 10, 20);
            middleImg.frame = CGRectMake(333, 255, 0, 20);
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 255, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(323, 255, 20, 20);
        }else if(height == 736){

            leftImg.frame = CGRectMake(357, 269, 10, 20);
            middleImg.frame = CGRectMake(367, 269, 0, 20);
             rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 269, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(357, 269, 20, 20);
        }
        

    }else if(unreadMsgCount.length == 3){
        if (height == 568) {
            leftImg.frame = CGRectMake(278, 226, 10, 20);
            middleImg.frame = CGRectMake(288, 226, 8, 20);
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 226, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(279, 226, 25, 20);
        }else if(height == 667){
            leftImg.frame = CGRectMake(323, 255, 10, 20);
        
            middleImg.frame = CGRectMake(333, 255, 8, 20);
        
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 255, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(324, 255, 25, 20);
        }else if(height == 736){
            leftImg.frame = CGRectMake(357, 269, 10, 20);
            middleImg.frame = CGRectMake(367, 269, 8, 20);
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 269, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(358, 269, 25, 20);

        }
        
    }else {
        unreadMsgCountLabel.text = @"...";
        if (height == 568) {
            leftImg.frame = CGRectMake(278, 226, 10, 20);
            middleImg.frame = CGRectMake(288, 226, 8, 20);
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 226, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(279, 226, 25, 20);
        }else if(height == 667){
            leftImg.frame = CGRectMake(323, 255, 10, 20);
        
            middleImg.frame = CGRectMake(333, 255, 7, 20);
        
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 255, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(322, 255, 30, 20);
            
        }else if(height == 736){
            leftImg.frame = CGRectMake(357, 269, 10, 20);
            middleImg.frame = CGRectMake(367, 269, 8, 20);
            rightImg.frame = CGRectMake(middleImg.frame.origin.x + middleImg.frame.size.width, 269, 10, 20);
            unreadMsgCountLabel.frame = CGRectMake(358, 269, 25, 20);
        }
    }
}
@end

