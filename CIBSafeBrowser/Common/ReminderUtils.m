//
//  ReminderUtils.m
//  CIBSafeBrowser
//
//  Created by 陈宇劢 on 15/12/14.
//  Copyright © 2015年 cib. All rights reserved.
//

#import "ReminderUtils.h"
#import <UIKit/UIKit.h>

@implementation ReminderUtils

+ (void)addReminder:(NSString *)serialNo WithTitle:(NSString *)title atTime:(NSTimeInterval)timeInterval {
    if (!serialNo) {
        return;
    }
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    localNoti.fireDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    localNoti.timeZone = [NSTimeZone defaultTimeZone];
    localNoti.alertTitle = @"提醒";
    localNoti.alertBody = title;
    localNoti.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *infoDic = [NSDictionary dictionaryWithObject:serialNo forKey:@"serialNo"];
    [localNoti setUserInfo:infoDic];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    
}

+ (void)cancelReminder:(NSString *)serialNo {
    if (!serialNo) {
        return;
    }
    NSArray *allLocalNoties = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNoti in allLocalNoties) {
        if ([[localNoti.userInfo objectForKey:@"serialNo"] isEqualToString:serialNo]) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNoti];
            break;
        }
    }
}

+ (void)cancelAllReminders {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
