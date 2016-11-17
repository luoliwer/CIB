//
//  GlobleData.h
//  spartacrm
//
//  Created by hunkzeng on 14-6-10.
//  Copyright (c) 2014年 vojo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobleData : NSObject
    + (GlobleData *) sharedInstance;

@property(nonatomic,strong) NSString *msgCount; //消息数量
@end
