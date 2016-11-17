//
//  AddToFavorTableViewController.h
//  CIBSafeBrowser
//
//  Created by cib on 14/12/9.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SuperViewController.h"
@interface AddToFavorTableViewController : SuperViewController<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITabBarDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end
