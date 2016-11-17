//
//  GroupInfoController.h
//  CIBSafeBrowser
//
//  Created by YangChao on 29/1/16.
//  Copyright © 2016年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInfoController : UIViewController

@property (nonatomic, strong) NSString *groupId;

//返回到指定的viewcontroller
@property (nonatomic, assign) NSString *backToViewControllerName;

@end
