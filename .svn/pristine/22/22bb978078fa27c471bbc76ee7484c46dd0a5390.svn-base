//
//  MessageCell.h
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageFrame;
@interface MessageCell : UITableViewCell

@property (nonatomic, strong) MessageFrame *msgFrame;

@property (nonatomic, strong) void (^ViewPic)(int fileType, NSString *filePath);//查看图片

@property (nonatomic, strong) void (^OpenUrlInNewView)(NSString *url, NSString *appNo); // 在新页面打开url

@property (nonatomic, strong) void (^OpenAppInNewTab)(NSString *appNo); //在新tab中打开webApp

@property (nonatomic, strong) void (^ViewOriginalImage)(UIImage *image); //查看原图

//@property (nonatomic, strong) NSString *sendPercent;//传输百分比

- (void)click; // cell的点击事件

@end
