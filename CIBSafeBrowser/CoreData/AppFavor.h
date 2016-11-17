//
//  AppFavors.h
//  CIBSafeBrowser
//
//  Created by yanyue on 16/7/12.
//  Copyright © 2016年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AppFavor : NSManagedObject

@property (nullable, nonatomic, retain) NSString *appName;
@property (nullable, nonatomic, retain) NSNumber *sortIndex;

@end
