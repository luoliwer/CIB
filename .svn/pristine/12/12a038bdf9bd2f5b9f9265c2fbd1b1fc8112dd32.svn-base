//
//  CIBURLCache.h
//  CIBSafeBrowser
//
//  Created by cib on 14/04/15.
//  Copyright (c) 2014 cib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"
#import "CIBResourceInfo.h"

@interface CIBURLCache : NSURLCache

@property(nonatomic, assign) NSInteger cacheTime;
@property(nonatomic, retain) NSString *diskPath;
@property(nonatomic, retain) NSMutableDictionary *responseDictionary;
@property(nonatomic, retain) NSMutableArray *blackList;  // 黑名单中的资源不缓存

/**
 *  定制一个NSURLCache
 *
 *  @param memoryCapacity cache占用内存，单位B
 *  @param diskCapacity cache占用硬盘，单位B
 *  @param diskPath cache路径，nil时使用默认路径[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
 *  @param cacheTime cache生命周期，单位秒，<=0时永不过期
 *
 *  @return CIBURLCache实例
 */
- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity
                diskCapacity:(NSUInteger)diskCapacity
                    diskPath:(NSString *)path
                   cacheTime:(NSInteger)cacheTime;

- (void)readLocalFileResourceToCache:(CIBResourceInfo *)resourceInfo;

@end
