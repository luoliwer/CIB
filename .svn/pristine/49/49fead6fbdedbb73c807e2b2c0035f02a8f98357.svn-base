//
//  EventMoble.h
//  INOYearCalendar
//
//  Created by wangzw on 15/6/25.
//  Copyright (c) 2015年 inostudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EventMoble : NSObject
@property(nonatomic,strong)NSString *eventid;//
@property(nonatomic,strong)NSDate *beginAlert;//提醒时间
@property(nonatomic,strong)NSDate *beginEvent;//事件开始时间
@property(nonatomic,strong)NSDate *endEvent;
@property(nonatomic,copy)NSString *title;//标题
@property(nonatomic,copy)NSString *content;//内容
@property(nonatomic)NSInteger timeCycle;//单位 秒 提醒周期


//添加提醒
+(void)addReminder:(EventMoble *)em;
@end
