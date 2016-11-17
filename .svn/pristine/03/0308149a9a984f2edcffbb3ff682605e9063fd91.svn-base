//
//  FirstViewController.h
//  CIBSafeBrowser
//
//  Created by cib on 14/12/4.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "CollectionFootView.h"

@interface FavorViewController : UIViewController
{
   SearchViewController *searchVC;
}

@property (strong, nonatomic) IBOutlet UICollectionView *favorCollectionView;
@property (nonatomic, strong) CollectionFootView *header;
@property (nonatomic, strong) NSMutableArray *appList;  // 书签列表
@property (nonatomic,assign) BOOL isEdit;
- (void)reloadFavors;  // 重新加载收藏列表
- (void)loadData;
@end

