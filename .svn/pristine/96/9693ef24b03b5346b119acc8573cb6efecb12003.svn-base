//
//  ViewPhotoController.m
//  CIBSafeBrowser
//
//  Created by cibdev-macmini-1 on 16/7/14.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "ViewPhotoController.h"

@interface ViewPhotoController ()
{
    UIImageView *_photoView;
    BOOL isScaled;
    UIScrollView *_scrollView;
}
@end

@implementation ViewPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
    
    _photoView = [[UIImageView alloc] init];
    _photoView.backgroundColor = [UIColor whiteColor];
    _photoView.frame = CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    [_scrollView addSubview:_photoView];
    
    //关闭当前视图
    UITapGestureRecognizer *closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    closeGesture.numberOfTapsRequired = 1;
    closeGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:closeGesture];
    
    //放缩图片
    UITapGestureRecognizer *scale = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    scale.numberOfTapsRequired = 2;
    scale.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer:scale];
    
    //这个方法是只有当双击事件失效或者失败后再执行单击事件
    [closeGesture requireGestureRecognizerToFail:scale];
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    //获取沙盒路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *appId = [[NSUserDefaults standardUserDefaults] valueForKey:@"PhotoEventHandleUtilsCurrentAppId"];
    //图片文件路径
    NSString *photoPath = [NSString stringWithFormat:@"%@/%@/%@", docPath, appId, imageName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:photoPath]) {
        NSData *data = [NSData dataWithContentsOfFile:photoPath];
        UIImage *image = [UIImage imageWithData:data];
        _photoView.image = image;
    } else {
        
    }
}

- (void)close:(UIGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scale:(UIPinchGestureRecognizer *)pinch
{
    if (!isScaled) {
        CGFloat scale = 2.0;
        _photoView.transform = CGAffineTransformScale(_photoView.transform, scale, scale);
        _photoView.frame = CGRectMake(0, 0, _photoView.bounds.size.width * scale, _photoView.bounds.size.height * scale);
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * scale, _scrollView.bounds.size.height * scale);
    } else {
        _photoView.transform = CGAffineTransformIdentity;
        _photoView.frame = CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width , _scrollView.bounds.size.height);
    }
    isScaled = !isScaled;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
