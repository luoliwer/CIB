//
//  AppInfo.h
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-9-1.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface AppInfo : NSManagedObject

@property (nonatomic, retain) NSNumber *appNo;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) NSString *showName;
@property (nonatomic, retain) NSString *indexURL; //加密存储
@property (nonatomic, retain) NSString *iconURL; //加密存储
@property (nonatomic, retain) NSString *releaseTime;
@property (nonatomic, retain) NSNumber *isFavorite;
@property (nonatomic, retain) NSNumber *favoriteTimeStamp;
@property (nonatomic, retain) NSNumber *notiNo;

@property (nonatomic, retain) NSNumber *sortIndex;



@end
