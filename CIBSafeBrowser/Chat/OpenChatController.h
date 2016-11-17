//
//  OpenChatController.h
//  ChatDemo
//
//  Created by YangChao on 20/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chatter.h"

@interface OpenChatController : UIViewController {
    
}

//群号
@property (nonatomic, strong) NSString *groupId;

//现有群成员
@property (nonatomic, strong) NSArray *groupHadMembers;


@property BOOL isFromShare; // 是否来自新闻/指标等WebApp的分享;
@property (nonatomic, strong) NSString *shareType; // 分享类型
@property (nonatomic, strong)NSString *shareContent; // 分享具体内容

@property IBOutlet UILabel *titleLabel; //标题


- (void)updateContact:(Chatter *)chatter;
@end
