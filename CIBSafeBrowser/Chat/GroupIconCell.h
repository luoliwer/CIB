//
//  GroupIconCell.h
//  CIBSafeBrowser
//
//  Created by YangChao on 29/1/16.
//  Copyright © 2016年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Chatter;

@interface GroupIconCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;

@property (strong, nonatomic) Chatter *chatter;

//删除事件
@property (nonatomic, strong) void (^DeleteGroupMember)(Chatter *chatter);

@end
