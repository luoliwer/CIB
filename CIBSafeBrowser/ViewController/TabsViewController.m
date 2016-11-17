//
//  TabsViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 15/3/13.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "TabsViewController.h"

#import "CustomWebViewController.h"
#import "AppDelegate.h"
#import "PageView.h"
#import "KUIButton.h"
#import "MainViewController.h"

#import "MyUtils.h"
#import "Config.h"
#import "UIImage+BlurGlass.h"
#import "TouchView.h"

#import "UILabel+LabelSizeOf.h"
#import "SDWebImageManager.h"
#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height

@interface TabsViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSInteger numberOfPages;  // 页面数
    NSInteger numberOfFreshPages;  // 需要更是视图的页面数（用于删除或更新）
    NSRange visibleIndexes;  // 可见页面范围
    PageView *selectedPage;  // 当前页（选中页）
    
    CGRect sourceIconImgRect;
}
@property (strong, nonatomic) IBOutlet UIScrollView *pageScrollView;  // 页面展示区
@property (strong, nonatomic) IBOutlet TouchView *pageScrollViewTouch;
@property (strong, nonatomic) NSMutableArray *visiblePages;  // 可见页
@property (strong, nonatomic) NSMutableArray *deletedPages;  // 待删页
@property (strong, nonatomic) NSMutableDictionary *reusablePages;  // 重用页面
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageScrollWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageScrollHeightConstraint;

// 以下用于动态增删页面
@property (nonatomic, retain) NSIndexSet *indexesBeforeVisibleRange;  // 可见页之前的范围
@property (nonatomic, retain) NSIndexSet *indexesWithinVisibleRange;  // 可见页范围
@property (nonatomic, retain) NSIndexSet *indexesAfterVisibleRange;  // 可见页之后的范围

@property (nonatomic, strong) UILabel *pageNumLabel;  // 当前页
@property (nonatomic, strong) UILabel *totalPageLabel;  // 总页数
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBtn;
@end

@implementation TabsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageScrollWidthConstraint.constant=(screenWidth*0.7)+20.0f;
    //110.0f = iconview.y+iconview.height;
     self.pageScrollHeightConstraint.constant=(screenHeight*0.7)+90.f;
    sourceIconImgRect=CGRectMake(0, 0, 50, 50);
    //增加主页背景(用于模糊化效果)
    if([AppDelegate delegate].mainScreenShot){
        [self.view addSubview:[AppDelegate delegate].mainScreenShot];
    }
    UIView* backGroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backGroundView.backgroundColor=[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image = [[MyUtils screenShotFromView:backGroundView] imgWithBlur];  // 默认配置即可
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:self.pageScrollView];
    [self.view bringSubviewToFront:self.toolBar];
    
    // 初始化内部数据结构
    self.visiblePages = [[NSMutableArray alloc] initWithCapacity:3];
    self.reusablePages = [[NSMutableDictionary alloc] initWithCapacity:3];
    self.deletedPages = [[NSMutableArray alloc] initWithCapacity:0];
    
    // set tap gesture recognizer for page selection
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureFrom:)];
    [self.pageScrollView addGestureRecognizer:recognizer];
    recognizer.delegate = self;
    
    // 设置用于展示tab页的scrollview
    self.pageScrollView.decelerationRate = 1.0;
    self.pageScrollView.delaysContentTouches = NO;
    self.pageScrollView.clipsToBounds = NO;
    self.pageScrollViewTouch.receiver = self.pageScrollView; // 扩展手势区域
    
    // 默认值
    numberOfPages = 1;
    visibleIndexes.location = 0;
    visibleIndexes.length = 1;
    
//    // 在这里loaddata不会有一闪的问题，但会出现第一页的位置的不正常，百思不得其解，留待玉麦解决（暂时移到viewDidAppear中调用）
//    [self reloadData];
    
    [self initPageControl:8];
}
-(void) initPageControl:(NSInteger) totalPage{
    UIView* contentView =[[UIView alloc] initWithFrame:CGRectMake(0,0,30,20)];
    
    [self.view addSubview:contentView];
    [self.view bringSubviewToFront:contentView];
    self.pageNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];//这个frame是初设的，没关系，后面还会重新设置size。
    [self.pageNumLabel setNumberOfLines:0];
    NSString *pageNum = @"1";
    if ([self numberOfPagesInScrollView] == 0) {
        pageNum = @"";
    }
    UIFont *font = [UIFont fontWithName:@"Arial" size:16];
    self.pageNumLabel.font=font;
    self.pageNumLabel.textColor=[UIColor whiteColor];
    self.pageNumLabel.text=pageNum;
    [self.pageNumLabel sizeToFit];
    self.pageNumLabel.frame=CGRectMake(0, 0, self.pageNumLabel.frame.size.width, self.pageNumLabel.frame.size.height);
    [contentView addSubview:self.pageNumLabel];
    
    self.totalPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];//这个frame是初设的，没关系，后面还会重新设置size。
    [self.totalPageLabel setNumberOfLines:0];
    NSString *s = [NSString stringWithFormat:@"   "];
    UIFont *font1 = [UIFont fontWithName:@"Arial" size:16];
    self.totalPageLabel.font=font1;
    self.totalPageLabel.textColor=[UIColor colorWithRed:59/255.0 green:164/255.0 blue:218/255.0 alpha:1.0];
    self.totalPageLabel.text=s;
    [self.totalPageLabel sizeToFit];
    self.totalPageLabel.frame=CGRectMake(self.pageNumLabel.frame.size.width, 0, self.totalPageLabel.frame.size.width, self.totalPageLabel.frame.size.height);
    [contentView addSubview:self.totalPageLabel];
    
    contentView.translatesAutoresizingMaskIntoConstraints=NO;
    float centerY = (screenHeight-(self.pageScrollHeightConstraint.constant+self.toolBar.frame.size.height))/2- contentView.frame.size.height/2;
    NSLayoutConstraint* myHConstraint =[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pageScrollView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:centerY];
//    myHConstraint.active=YES;
    [self.view addConstraint:myHConstraint];
    
    NSLayoutConstraint* myVConstraint =[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:0.94f constant:0.0f];
//    myVConstraint.active=YES;
    [self.view addConstraint:myVConstraint];
}
- (IBAction)stopActon:(id)sender {

    AppDelegate *appDelegate = [AppDelegate delegate];
    
    // 页面跳转
    UIViewController *currentRootVC = appDelegate.window.rootViewController;
    if ([currentRootVC isKindOfClass:[MainViewController class]]) {
        // 如果从主页打开tab页，直接返回主页
        if ([self.presentingViewController isKindOfClass:[MainViewController class]]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        // 从WebApp页面打开tab页
        else if ([self.presentingViewController isKindOfClass:[CustomWebViewController class]]) {
            // 来源页面已经被关闭，回到首页
            if (![appDelegate.tabList containsObject:self.presentingViewController]) {
                [currentRootVC dismissViewControllerAnimated:YES completion:nil];
            }
            else { // 返回来源页面
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            NSLog(@"tab页是由 %@ present出来的", NSStringFromClass([self.presentingViewController class]));
        }
    }
    else {
        NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
    }
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadData];
    
}

// 是否支持转屏
- (BOOL)shouldAutorotate {
    return YES;
}
// 支持的屏幕方向
- (NSUInteger)supportedInterfaceOrientations {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        return UIInterfaceOrientationMaskAll;
    }
    else {  // iPhone&iPod
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)closeBtnTouch:(UITapGestureRecognizer *)sender{
    NSInteger senderTag = sender.view.tag;
    if(senderTag==2003){
        KUIButton* button = (KUIButton*)sender.view;
        [self closeBtnPress:button];
//        if([self.visiblePages count]==1){
//            [self stopClick:sender];
//        }
    }
   
}

- (IBAction)closeBtnPress:(KUIButton *)button {
    // 获取该页index
    NSInteger i = 0;
    for (; i < [AppDelegate delegate].tabList.count; i++) {
        CustomWebViewController *vc = [[AppDelegate delegate].tabList objectAtIndex:i];
        if ([vc.requestURL isEqual:button.idxString]) {
            [vc.webview stopLoading];
            NSMutableIndexSet *indexesToDelete = [[NSMutableIndexSet alloc] initWithIndex:i];  // 获取删除的范围
            [[AppDelegate delegate].tabList removeObjectsAtIndexes:indexesToDelete];  // 清空相关数据项
            [self deletePagesAtIndexes:indexesToDelete animated:YES];  // 更新scrollview
            vc = nil;
            break;
        }
    }
    
    // 没有了就自动返回
    if ([self numberOfPagesInScrollView] == 0) {
        AppDelegate *appDelegate = [AppDelegate delegate];
        UIViewController *currentRootVC = appDelegate.window.rootViewController;
        // 根据vc判断一下用户是从哪个页面进的tab页
        // 从主页进入tab页的
        if ([currentRootVC isKindOfClass:[MainViewController class]]) {
            [currentRootVC dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
        }
    }
}


#pragma mark -
#pragma mark Info
// 返回index的page，不在可见页中时返回nil
- (UIView *)pageAtIndex:(NSInteger)index {
    if (index == NSNotFound || index < visibleIndexes.location
        || index > visibleIndexes.location + visibleIndexes.length - 1) {
        return nil;
    }
    return [self.visiblePages objectAtIndex:index - visibleIndexes.location];
}

#pragma mark -
#pragma mark Page Selection
// 返回当前选中页index
- (NSInteger)indexForSelectedPage {
    return [self indexForVisiblePage:selectedPage];
}

// 返回page的index，不在可见页中时返回NSNotFound
- (NSInteger)indexForVisiblePage:(UIView*)page {
    NSInteger index = [self.visiblePages indexOfObject:page];
    if (index != NSNotFound) {
        return visibleIndexes.location + index;
    }
    return NSNotFound;
}

// scroll到特定页位置
- (void) scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    CGPoint offset = CGPointMake(index * self.pageScrollView.frame.size.width, 0);
    [self.pageScrollView setContentOffset:offset animated:animated];
}

// 选中某页时的处理
- (void) selectPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    // 无效index不做处理
    if (index == NSNotFound || numberOfPages == 0) {
        return;
    }
    
    AppDelegate *appDelegate = [AppDelegate delegate];
    UIViewController *vc = [appDelegate.tabList objectAtIndex:index];
    // 页面跳转
    UIViewController *currentRootVC = appDelegate.window.rootViewController;
    if ([currentRootVC isKindOfClass:[MainViewController class]]) {
        if (currentRootVC.presentedViewController) {
            [currentRootVC dismissViewControllerAnimated:NO completion:^{
                [currentRootVC presentViewController:vc animated:YES completion:nil];
            }];
        }
        else {
            [currentRootVC presentViewController:vc animated:YES completion:nil];
        }
    }
    else {
        NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
    }
}

#pragma mark - PageScroller Data

// 加载当前的tab数据
- (void)reloadData {
    NSInteger selectedIndex = selectedPage ? [self.visiblePages indexOfObject:selectedPage] : NSNotFound;
    
    // 清空页面
    [self.visiblePages removeAllObjects];
    [[self.pageScrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    NSInteger numPages = [self numberOfPagesInScrollView];
    [self setNumberOfPages:numPages];
   

    if (numPages > 0) {
        // 重新加载可见页面(第一次只有一页)
        for (int index = 0; index < visibleIndexes.length; index++) {
            UIView *page = [self loadPageAtIndex:visibleIndexes.location + index insertIntoVisibleIndex:index];
            [self addPageToScrollView:page atIndex:visibleIndexes.location + index];
        }
        
        // 计算可见页面
        [self updateVisiblePages];
        
        // 无预先设置时默认选中第一页
        if (selectedIndex == NSNotFound) {
            selectedPage = [self.visiblePages objectAtIndex:0];
        }
        else {
            selectedPage = [self.visiblePages objectAtIndex:selectedIndex];
        }
        
        [self refreshView:1];
        // 首次不加延迟设置位置不生效 纳闷
        [self performSelector:@selector(scaleLayer) withObject:nil afterDelay:0.1];
    }
}
-(void) scaleLayer{
    //设置缩放
    for(PageView* view in self.visiblePages){
        if(![view.appNameLabel.text isEqualToString:selectedPage.appNameLabel.text]){
            float targetWidth =[[UIScreen mainScreen] bounds].size.width*0.65;
            float currWidth = [[UIScreen mainScreen] bounds].size.width*0.7;
            float bi = targetWidth/currWidth;
            view.snapshotImg.transform = CGAffineTransformMakeScale(bi, bi);
            view.snapshotImg.alpha=0.8;
            [self setIconFrameWithSuperView:view type:0];
            
            view.hidden=NO;
            view.closeBtn.hidden=YES;
        }
    }
}
//刷新界面数据
-(void) refreshView:(NSInteger) selectedIndex{
    //设置页码
    self.totalPageLabel.text=[NSString stringWithFormat:@"/%d",(int)numberOfPages];
    self.pageNumLabel.text=[NSString stringWithFormat:@"%d",(int)selectedIndex];
    //设置放大
    selectedPage.snapshotImg.transform = CGAffineTransformMakeScale(1,1);
    [self setIconFrameWithSuperView:selectedPage type:1];
    selectedPage.snapshotImg.alpha=1.0;
    selectedPage.hidden=NO;
    selectedPage.closeBtn.hidden=NO;
}
//设置logo 位置
-(void) setIconFrameWithSuperView:(PageView*) view type:(NSInteger) type{
    //正常
    CGRect IconRect = view.iconImg.frame;
    if(type==1){
        IconRect.size.width=sourceIconImgRect.size.width;
        IconRect.size.height=sourceIconImgRect.size.height;
        IconRect.origin.x=view.snapshotImg.frame.origin.x;
        IconRect.origin.y=view.snapshotImg.frame.origin.y-sourceIconImgRect.size.height-20;//
        view.iconImg.frame=IconRect;
        view.appNameLabel.hidden=NO;
    }else{
    //缩放
        IconRect.size.width=sourceIconImgRect.size.width*0.8;
        IconRect.size.height=sourceIconImgRect.size.height*0.8;
        IconRect.origin.x=view.snapshotImg.frame.origin.x;
        IconRect.origin.y=view.snapshotImg.frame.origin.y-sourceIconImgRect.size.height-10;//
        view.iconImg.frame=IconRect;
         view.appNameLabel.hidden=YES;
    }

}

// 加载index的页面到可见页数组
- (UIView *)loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger) visibleIndex {
    // 为页面获取一张view
    static NSString *pageId = @"id";
    PageView *visiblePage =(PageView *)[self dequeueReusablePageWithIdentifier:pageId];  // 首先使用可重用view(self.view.frame.size.width / 5)*3
    if (!visiblePage) {
        //图片缩小为原尺寸的0.7倍（已在故事版中设置了pagescrollview的宽度）
        CGRect frame = CGRectMake(0, 0,(screenWidth*0.7)+30.0f, self.pageScrollView.frame.size.height);
        
        
        visiblePage = [[PageView alloc] initWithFrame:frame];
        frame.size.height=visiblePage.snapshotImg.frame.origin.y+(screenHeight*0.7);
        visiblePage.frame=frame;
//        self.pageScrollHeightConstraint.constant=frame.size.height;
        
        
        UITapGestureRecognizer *recognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBtnTouch:)];
        [visiblePage.closeBtn addGestureRecognizer:recognizer1];
       
    }
    // 加载对应显示数据
    CustomWebViewController *vc = [[AppDelegate delegate].tabList objectAtIndex:index];
    visiblePage.snapshotImg.image = [MyUtils screenShotFromView:vc.view];
    visiblePage.closeBtn.idxString = vc.requestURL;
    //[MyUtils propertyOfResource:@"Setting" forKey:@"ProxyList"];
   NSString* iconName= [MyUtils propertyOfResource:@"iconLogo" forKey:vc.pageTitle];
     //图标赋值
    if(iconName){
        visiblePage.iconImg.image=[UIImage imageNamed:iconName];
    }else{
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage* image = [[manager imageCache] imageFromMemoryCacheForKey:vc.iconUrl];
        if (image) {
            visiblePage.iconImg.image=image;
        }
    }
   
    visiblePage.appNameLabel.text=vc.pageTitle;
    
    // adjust content size of scroll view
    UIScrollView *pageContentsScrollView = (UIScrollView*)[visiblePage viewWithTag:10];
    pageContentsScrollView.scrollEnabled = NO; // initially disable scroll
    
    // 使该张view可重用
    NSMutableArray *reusables = [self.reusablePages objectForKey:pageId];
    if (!reusables) {
        reusables = [[NSMutableArray alloc] initWithCapacity : 4] ;
    }
    if (![reusables containsObject:visiblePage]) {
        [reusables addObject:visiblePage];
    }
    [self.reusablePages setObject:reusables forKey:pageId];
    
    // 添加到可见页数组
    [self.visiblePages insertObject:visiblePage atIndex:visibleIndex];
    
    return visiblePage;
}


// 添加page到scrollview中（在index相对应位置）
- (void)addPageToScrollView:(UIView*)page atIndex:(NSInteger) index {
    // 设置page在scrollview中的位置
    page.hidden=YES;
    [self setFrameForPage:page atIndex:index];
    
    // 添加到scrollview
    [self.pageScrollView insertSubview:page atIndex:0];
}

// 在scrollview中index位置插入page，（动画）将index后的页面向后推
- (void) insertPageInScrollView:(UIView *)page atIndex:(NSInteger)index animated:(BOOL)animated {
    // 添加page到scrollview中（在index相对应位置）
    [self addPageToScrollView:page atIndex:index];
    
    // 更新之后页面的offset
    [[self.pageScrollView subviews] enumerateObjectsUsingBlock:^(id existingPage, NSUInteger idx, BOOL *stop) {
        if (existingPage != page && page.frame.origin.x <= ((UIView *)existingPage).frame.origin.x) {
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^(void) {
                    [self shiftPage:existingPage withOffset:self.pageScrollView.frame.size.width];
                }];
            }
            else {
                [self shiftPage:existingPage withOffset:self.pageScrollView.frame.size.width];
            }
        }
    }];
}

// 在scrollview中删除page，（动画）将之后的页面向前推
- (void) removePagesFromScrollView:(NSArray *)pages animated:(BOOL)animated {
    CGFloat selectedPageOffset = NSNotFound;
    if ([pages containsObject:selectedPage]) {
        selectedPageOffset = selectedPage.frame.origin.x;
    }
    
    // 在scrollview中删
    [pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (animated) {
            [UIView animateWithDuration:0.2
                             animations:^{((UIView *)obj).alpha = 0.0f;}
                             completion:^(BOOL finished) {
                                 [obj removeFromSuperview];
                                 ((UIView *)obj).alpha = 1.0f;
                             }];
        }
        else {
            [obj removeFromSuperview];
        }
    }];
    
    // 之后的页面向前推
    [[self.pageScrollView subviews] enumerateObjectsUsingBlock:^(id remainingPage, NSUInteger idx, BOOL *stop) {
        NSIndexSet *removedPages = [pages indexesOfObjectsPassingTest:^BOOL(id removedPage, NSUInteger idx, BOOL *stop) {
            return ((UIView*)removedPage).frame.origin.x < ((UIView*)remainingPage).frame.origin.x;
        }];
        
        if ([removedPages count] > 0) {
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^(void) {
                    [self shiftPage : remainingPage withOffset: -([removedPages count] * self.pageScrollView.frame.size.width)];
                }];
            }
            else {
                [self shiftPage : remainingPage withOffset: -([removedPages count] * self.pageScrollView.frame.size.width)];
            }
        }
    }];
    
    // 如果之前的当前页(选中页)被删，再搞一个
    if(selectedPageOffset != NSNotFound){
        NSInteger index = [[self.pageScrollView subviews] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            CGFloat delta = fabsf(((UIView*)obj).frame.origin.x - selectedPageOffset);
            return delta < 0.1;
        }];
        
        UIView *newSelectedPage = nil;
        if (index != NSNotFound) {  // 更新选中页
            newSelectedPage = [[self.pageScrollView subviews] objectAtIndex:index];
        }

        if([self indexForVisiblePage:newSelectedPage] == NSNotFound) {  // 如果最后一页被删，当前选中页为可见页最后一页
            newSelectedPage = [self.visiblePages lastObject];
        }
        
        NSInteger newSelectedPageIndex = [self indexForVisiblePage:newSelectedPage];
        if (newSelectedPage != selectedPage) {
            [self updateScrolledPage:newSelectedPage index:newSelectedPageIndex];
        }
    }
    
}

// 设置page在scrollview中的位置
- (void)setFrameForPage:(UIView *)page atIndex:(NSInteger)index {
    // page本身就设置为屏幕一半了
//    page.transform = CGAffineTransformMakeScale(0.9, 0.9);  // 原来全屏的，现在缩小为屏幕一半
    CGFloat contentOffset = index * self.pageScrollView.frame.size.width;
    CGFloat margin = (self.pageScrollView.frame.size.width - page.frame.size.width) / 2;
    
    CGRect frame = page.frame;
    frame.origin.x = contentOffset + margin;
    frame.origin.y = 0.0;//(self.pageScrollView.frame.size.height-frame.size.height)/2;
    page.frame = frame;
}

// page大挪移
- (void)shiftPage:(UIView *)page withOffset:(CGFloat) offset {
    CGRect frame = page.frame;
    frame.origin.x += offset;
    page.frame = frame; 
    
}
//计算page 中的图片尺寸
-(void) getImageHeight:(UIView *) page targetWidth:(float) targetWidth{

}


#pragma mark - insertion/deletion/reloading

// 计算可见页之前的范围、可见页范围、可见页之后的范围
- (void) prepareForDataUpdateWthIndexSet:(NSIndexSet *)indexes {
    self.indexesBeforeVisibleRange = nil;
    self.indexesBeforeVisibleRange = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (idx < visibleIndexes.location);
    }];
    
    self.indexesWithinVisibleRange = nil;
    self.indexesWithinVisibleRange = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (idx >= visibleIndexes.location &&
                (visibleIndexes.length > 0 ? idx < visibleIndexes.location + visibleIndexes.length : YES));
    }];
    
    self.indexesAfterVisibleRange = nil;
    self.indexesAfterVisibleRange = [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return ((visibleIndexes.length > 0 ? idx >= visibleIndexes.location + visibleIndexes.length : NO));
    }];
}

// 删除indexes指示的页面
- (void)deletePagesAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated {
    
    [self prepareForDataUpdateWthIndexSet:indexes];
    
    // 处理可见页范围之前的删除
    [self.indexesBeforeVisibleRange enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        // 因为界面重用的原因，可见页之前的页面实际是不存在的，所以新搞一个实例用于删除（shift之后页面时避免报错）
        UIView *pseudoPage = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] ;
        [self setFrameForPage:pseudoPage atIndex:idx];
        [self.deletedPages addObject:pseudoPage];
        visibleIndexes.location--;
    }];
    // 根据要删除页数处理offset等
    if ([self.deletedPages count] > 0) {
        CGFloat oldOffset = self.pageScrollView.contentOffset.x;
        [self setNumberOfPages:numberOfPages - [self.deletedPages count]];
        
        [self removePagesFromScrollView:self.deletedPages animated:NO];  // 不可见页的删除无需动画
        CGFloat newOffset = oldOffset - ([self.deletedPages count] * self.pageScrollView.frame.size.width);
        self.pageScrollView.contentOffset = CGPointMake(newOffset, self.pageScrollView.contentOffset.y);
        [self.deletedPages removeAllObjects];
    }
    
    // 处理可见页范围和之后的删除
    numberOfFreshPages = 0;
    NSInteger numPagesAfterDeletion = numberOfPages -= [self.indexesWithinVisibleRange count] + [self.indexesAfterVisibleRange count];
    [self.indexesWithinVisibleRange enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        // 获取待删页
        [self.deletedPages addObject:[self pageAtIndex:idx]];
        
        // 加载页面填充删除页面
        if (visibleIndexes.location + visibleIndexes.length <= numPagesAfterDeletion) {
            // 加载新页面
            NSInteger newPageIndex = visibleIndexes.location+visibleIndexes.length - [self.deletedPages count];
            UIView *page = [self loadPageAtIndex:newPageIndex insertIntoVisibleIndex:visibleIndexes.length];
            
            // 页面删除后，新页面将进入
            [self addPageToScrollView:page atIndex:newPageIndex + [self.indexesWithinVisibleRange count] ];
            numberOfFreshPages++;
        }
        
    }];
    
    // 更新可见页位置
    NSInteger deleteCount = [self.deletedPages count];
    if (deleteCount > 0 && numberOfFreshPages < deleteCount) {
        // 将进入的新页面不如删除的多，表明到尾了，调用最后两页
        NSInteger newLength = visibleIndexes.length - deleteCount + numberOfFreshPages;
        if (newLength >= 2) {  // 够两页直接更新
            visibleIndexes.length = newLength;
        }
        else {  // 不够调前面的
            if (visibleIndexes.location == 0){
                visibleIndexes.length = newLength;
            }
            else {
                NSInteger delta = MIN(2 - newLength, visibleIndexes.location);
                visibleIndexes.length = newLength + delta;
                visibleIndexes.location -= delta;
                
                // load 'delta' pages from before the visible range to replace deleted pages
                for (int i = 0; i < delta; i++) {
                    UIView *page = [self loadPageAtIndex:visibleIndexes.location + i insertIntoVisibleIndex:i];
                    [self addPageToScrollView:page atIndex:visibleIndexes.location + i ];
                }
            }
        }
    }
    
    numberOfPages = numPagesAfterDeletion;
    [self.visiblePages removeObjectsInArray:self.deletedPages]; // 从可见页数组中删除标记为删除的页
    [self removePagesFromScrollView:self.deletedPages animated:animated]; // 从scrollView中删除标记为删除的页
    // 更新ScrollView、pagecontrol
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^(void) {
            [self setNumberOfPages:numPagesAfterDeletion];
        }];
    } else {
        [self setNumberOfPages:numPagesAfterDeletion];
    }
    
    [self.deletedPages removeAllObjects];
    
    // 更新选中页
    [self scrollViewDidScroll:self.pageScrollView];
    
}


// 根据页数设置ScrollView、pagecontrol
- (void)setNumberOfPages:(NSInteger)number {
    numberOfPages = number;
    self.pageScrollView.contentSize = CGSizeMake(numberOfPages * self.pageScrollView.bounds.size.width, self.pageScrollView.bounds.size.height);
//    self.pageSelector.numberOfPages = numberOfPages;
}

// 滚完，设置页面
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算可见页列表
    [self updateVisiblePages];
    
    // 更新页面
    CGFloat delta = scrollView.contentOffset.x - selectedPage.frame.origin.x;
    BOOL toggleNextItem = (fabs(delta) > scrollView.frame.size.width / 2);
    if (toggleNextItem && [self.visiblePages count] > 1) {
        NSInteger selectedIndex = [self.visiblePages indexOfObject:selectedPage];
        BOOL neighborExists = ((delta < 0 && selectedIndex > 0) || (delta > 0 && selectedIndex < [self.visiblePages count] - 1));
        
        if (neighborExists) {
            NSInteger neighborPageVisibleIndex = [self.visiblePages indexOfObject:selectedPage] + (delta > 0 ? 1 : -1);
            UIView *neighborPage = [self.visiblePages objectAtIndex:neighborPageVisibleIndex];
            NSInteger neighborIndex = visibleIndexes.location + neighborPageVisibleIndex;
            
            [self updateScrolledPage:neighborPage index:neighborIndex];
        }
    }
    //缩放两边
    [self scaleLayer];
}


- (void) updateScrolledPage:(UIView *)page index:(NSInteger)index {
    if (!page) {
        selectedPage = nil;
    }
    else {
        selectedPage = page; // 更新选中页
    }
    [self refreshView:index+1];
    
}

// 计算（更新）可见页列表
- (void) updateVisiblePages {
    CGFloat pageWidth = self.pageScrollView.frame.size.width;
    
    // 计算之前可见页中左和右页的新x坐标（左页左边、右页右边）
    CGFloat leftViewOriginX = self.pageScrollView.frame.origin.x - self.pageScrollView.contentOffset.x + (visibleIndexes.location * pageWidth);
    CGFloat rightViewOriginX = self.pageScrollView.frame.origin.x - self.pageScrollView.contentOffset.x + (visibleIndexes.location+visibleIndexes.length-1) * pageWidth;
    
    if (leftViewOriginX > 0) {  // 左侧有新页进入
        if (visibleIndexes.location > 0) { // 是否是第一页
            visibleIndexes.length += 1;
            visibleIndexes.location -= 1;
            UIView *page = [self loadPageAtIndex:visibleIndexes.location insertIntoVisibleIndex:0];
            // 添加page到scrollview中
            [self addPageToScrollView:page atIndex:visibleIndexes.location ];
            
        }
    }
    else if(leftViewOriginX < -pageWidth) { // 左页超出可见区
        UIView *page = [self.visiblePages objectAtIndex:0];
        [self.visiblePages removeObject:page];
        [page removeFromSuperview];
        visibleIndexes.location += 1;
        visibleIndexes.length -= 1;
    }
    if (rightViewOriginX > self.view.frame.size.width) {// 右页超出可见区
        UIView *page = [self.visiblePages lastObject];
        [self.visiblePages removeObject:page];
        [page removeFromSuperview]; //remove from the scroll view
        visibleIndexes.length -= 1;
    }
    else if(rightViewOriginX + pageWidth < self.view.frame.size.width){ // 右侧有新页进入
        if (visibleIndexes.location + visibleIndexes.length < numberOfPages) { // 是否最后一页
            visibleIndexes.length += 1;
            NSInteger index = visibleIndexes.location+visibleIndexes.length-1;
            UIView *page = [self loadPageAtIndex:index insertIntoVisibleIndex:visibleIndexes.length-1];
            [self addPageToScrollView:page atIndex:index];
        }
    }
}



// 用于重用页面的view
- (UIView *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
    UIView *reusablePage = nil;
    NSArray *reusables = [self.reusablePages objectForKey:identifier];
    if (reusables){
        NSEnumerator *enumerator = [reusables objectEnumerator];
        while ((reusablePage = [enumerator nextObject])) {
            if(![self.visiblePages containsObject:reusablePage]){
                reusablePage.transform = CGAffineTransformIdentity;
                break;
            }
        }
    }
    return reusablePage;
}

#pragma mark - Handling Touches

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {  // 避免覆盖关闭按钮
        return NO;
    }
    
    if (!self.pageScrollView.decelerating && !self.pageScrollView.dragging) {
        return YES;
    }
    return NO;
}
// 响应tap
- (void)handleTapGestureFrom:(UITapGestureRecognizer *)recognizer {
    if (!selectedPage)
        return;
    NSInteger selectedIndex = [self indexForSelectedPage]; // 默认中间页
    CGPoint location = [recognizer locationInView:self.view];
    if (selectedIndex > 0 && location.x < self.pageScrollView.frame.origin.x) {  // 左页
        selectedIndex -= 1;
    }
    else if (selectedIndex < [self numberOfPagesInScrollView] - 1
             && location.x > self.pageScrollView.frame.origin.x + self.pageScrollView.frame.size.width) {  // 右页
        selectedIndex += 1;
    }
    
    [self selectPageAtIndex:selectedIndex animated:YES];
}

- (NSInteger)numberOfPagesInScrollView {
    return [AppDelegate delegate].tabList.count;
}
@end
