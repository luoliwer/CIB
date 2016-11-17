//
//  NewesCell.h
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Message;
@interface NewsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *newsFromer;
@property (weak, nonatomic) IBOutlet UILabel *newsContentLb;
@property (weak, nonatomic) IBOutlet UILabel *newsTime;
@property (weak, nonatomic) IBOutlet UILabel *msgNumLb;

@property (strong, nonatomic) Message *message;

@end
