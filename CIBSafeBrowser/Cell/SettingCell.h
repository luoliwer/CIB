//
//  AppCell.h
//  CIBSafeBrowser
//
//  Created by cib on 14/12/5.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *detail;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconConstraintWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconConstraintHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *moreConstraintHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *moreConstraintWidth;
@property (strong, nonatomic) IBOutlet UIImageView *moreBtn;

@end
