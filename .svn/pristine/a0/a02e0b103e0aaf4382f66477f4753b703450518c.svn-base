//
//  MainViewController.h
//  CIBSafeBrowser
//
//  Created by cib on 15/2/10.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

typedef NS_ENUM(NSUInteger, MainViewControllerState)
{
    MainViewControllerStateRolled = 0,  // 搜索框在顶部
    MainViewControllerStateStreched,  // 搜索框在中部,logo展开
    MainViewControllerStateStreching,  // 正在展开
    MainViewControllerStateRolling  // 正在收缩
};

@interface MainViewController : SuperViewController

@property (strong, nonatomic) IBOutlet UIView *navigationBarView;
@property (strong, nonatomic) IBOutlet UIView *searchContainerView;  // 搜索区

@property(nonatomic, assign) MainViewControllerState mainViewState;

- (void)reloadFavorCollectionView; // 刷新收藏webapp
- (void)loadCACertificate:(void(^)(BOOL ifSucc)) resultBlock toView:(UIView*) currView;
@end
