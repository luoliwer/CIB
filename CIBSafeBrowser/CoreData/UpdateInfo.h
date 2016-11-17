//
//  UpdateInfo.h
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-10-20.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface UpdateInfo : NSManagedObject

@property (nonatomic, retain) NSString *updateName;
@property (nonatomic, retain) NSNumber *updateTime;

@end
