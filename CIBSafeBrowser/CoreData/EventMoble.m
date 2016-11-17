//
//  EventMoble.m
//  INOYearCalendar
//
//  Created by wangzw on 15/6/25.
//  Copyright (c) 2015年 inostudio. All rights reserved.
//

#import "EventMoble.h"

@implementation EventMoble
+ (void)addReminder:(EventMoble *)em
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        //设置推送时间
        noti.fireDate = em.beginAlert;
        //设置时区
        noti.timeZone = [NSTimeZone defaultTimeZone];
        //设置重复间隔
        if (em.timeCycle<60) {
            noti.repeatInterval = 0;
        }else if (em.timeCycle == 60*60)
        {
            noti.repeatInterval = NSCalendarUnitHour;
            
        }else if (em.timeCycle == 60*120)
        {
            noti.repeatInterval = NSCalendarUnitHour;
            
        }
        //推送声音
        noti.soundName = UILocalNotificationDefaultSoundName;
        //内容
        noti.alertBody = em.title;
        //显示在icon上的红色圈中的数子
        noti.applicationIconBadgeNumber ++;
        //设置userinfo 方便在之后需要撤销的时候使用
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:em.eventid forKey:@"key"];
        noti.userInfo = infoDic;
        //添加推送到uiapplication
        UIApplication *app = [UIApplication sharedApplication];
        app.applicationIconBadgeNumber +=1;
        for (UILocalNotification *tmp in app.scheduledLocalNotifications)
        {
            if ([[tmp.userInfo objectForKey:@"key"]isEqualToString:em.eventid])
            {
                [app cancelLocalNotification:tmp];
            }
        }
        
        [app scheduleLocalNotification:noti];
        
        switch (em.timeCycle) {
            case 60*15:
            {
                noti.fireDate = [NSDate dateWithTimeInterval:15*60 sinceDate:noti.fireDate];
                [app scheduleLocalNotification:noti];
                noti.fireDate = [NSDate dateWithTimeInterval:15*60 sinceDate:noti.fireDate];
                [app scheduleLocalNotification:noti];
                noti.fireDate = [NSDate dateWithTimeInterval:15*60 sinceDate:noti.fireDate];
                [app scheduleLocalNotification:noti];
            }
                break;
            case 60*30:
            {
                noti.fireDate = [NSDate dateWithTimeInterval:30*60 sinceDate:noti.fireDate];
                [app scheduleLocalNotification:noti];
            }
                break;
                
            case 60*120:
            {
                for (int i = 0; i<(24*60*60/120*60); i++)
                {
                    noti.fireDate = [NSDate dateWithTimeInterval:120*60 sinceDate:noti.fireDate];
                    [app scheduleLocalNotification:noti];
                }
            }
                break;
            default:
                break;
        }
    }
}
@end
