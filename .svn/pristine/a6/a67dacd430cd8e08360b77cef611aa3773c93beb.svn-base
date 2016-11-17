//
//  CIBURLCache.m
//  CIBSafeBrowser
//
//  Created by cib on 14/04/15.
//  Copyright (c) 2014 cib. All rights reserved.
//

#import "CIBURLCache.h"
#import "Reachability.h"
#import "MyUtils.h"

@interface CIBURLCache(private)

- (NSString *)cacheFolder;
- (NSString *)cacheFilePath:(NSString *)file;
- (NSString *)cacheRequestFileName:(NSString *)requestUrl;
- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl;
- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request;
- (void)deleteCacheFolder;

@end

@implementation CIBURLCache

@synthesize cacheTime = _cacheTime;
@synthesize diskPath = _diskPath;
@synthesize responseDictionary = _responseDictionary;
@synthesize blackList = _blackList;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime {
    if (self = [self initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        self.cacheTime = cacheTime;
        if (path)
            self.diskPath = path;
        else
            self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        self.responseDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    NSString *urlWithoutParameter = [NSString stringWithFormat:@"%@://%@:%@%@", request.URL.scheme, request.URL.host, request.URL.port ,request.URL.relativePath];
    
    if ([self.blackList containsObject:urlWithoutParameter]) {
        return [super cachedResponseForRequest:request];
    }
    
    return [self dataFromRequest:request];
}

- (void)removeAllCachedResponses {
    [super removeAllCachedResponses];
    
    [self deleteCacheFolder];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    [super removeCachedResponseForRequest:request];
    
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:otherInfoPath error:nil];
}

#pragma mark - custom url cache

- (NSString *)cacheFolder {
    return @"URLCACHE";
}

- (void)deleteCacheFolder {
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

- (NSString *)cacheFilePath:(NSString *)file {
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        
    } else {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@", path, file];
}

- (NSString *)cacheRequestFileName:(NSString *)requestUrl {
    return [MyUtils MD5Digest:requestUrl];
}

- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl {
    return [MyUtils MD5Digest:[NSString stringWithFormat:@"%@-otherInfo", requestUrl]];
}

- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request {
    
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSDate *date = [NSDate date];
    
    NSDictionary *headerDic = [request allHTTPHeaderFields];
    __block NSString *versionCode = [headerDic objectForKey:@"versionCode"];
    __block NSString *mimeType = [headerDic objectForKey:@"mimeType"];
    __block NSString *encodingType = [headerDic objectForKey:@"encodingType"];
    
    NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
    NSString *currentVersionCode = [otherInfo objectForKey:@"versionCode"];
//    NSString *currentMimeType = [otherInfo objectForKey:@"MIMEType"];
//    NSString *currentEncodingType = [otherInfo objectForKey:@"textEncodingName"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        
        // 先看一下本地文件的versionCode，小于等于0则代表非服务端列表里的文件
        if ([currentVersionCode intValue] <= 0) {
            BOOL expire = false;
            
            if (self.cacheTime > 0) {
                NSInteger createTime = [[otherInfo objectForKey:@"time"] intValue];
                if (createTime + self.cacheTime < [date timeIntervalSince1970]) {
                    expire = true;
                }
            }
            
            if (expire == false) {
                NSLog(@"data from cache: %@", url);
                
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
                                                                    MIMEType:[otherInfo objectForKey:@"MIMEType"]
                                                       expectedContentLength:data.length
                                                            textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                
                return cachedResponse;
            }
            else {
                NSLog(@"cache expire: %@", url);
                
                [fileManager removeItemAtPath:filePath error:nil];
                [fileManager removeItemAtPath:otherInfoPath error:nil];
            }
        }
        else {
            // 这是服务端列表里的缓存文件，先看一下request里的versionCode。如果为空则代表从正常请求进来，如果非空则代表从服务端更新资源列表后手动发起请求。
            if (versionCode && ([versionCode intValue] > [currentVersionCode intValue])) {
                NSLog(@"cache has newer version: %@", url);
                
                [fileManager removeItemAtPath:filePath error:nil];
                [fileManager removeItemAtPath:otherInfoPath error:nil];
            }
            else {
                NSLog(@"data from cache: %@", url);
                
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
                                                                    MIMEType:[otherInfo objectForKey:@"MIMEType"]
                                                       expectedContentLength:data.length
                                                            textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                
                return cachedResponse;
            }
        }
    }
    
    if (![MyUtils isNetworkAvailable]) {
        return nil;
    }
    
    // 下面是本地缓存文件不存在的情况，先看一下request里的versionCode，为空则代表非服务端列表里面的文件
    
    //  不缓存非服务端列表里的文件了
    if (!versionCode || [versionCode intValue] <= 0) {
        return nil;
    }
    
    __block NSCachedURLResponse *cachedResponse = nil;
    //sendSynchronousRequest请求也要经过NSURLCache
    //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    id boolExsite = [self.responseDictionary objectForKey:url];
    if (boolExsite == nil) {
        [self.responseDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:url];
  
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (response && data) {
                
                [self.responseDictionary removeObjectForKey:url];
                
                if (error) {
                    NSLog(@"error: %@", error);
                    NSLog(@"not cached: %@", request.URL.absoluteString);
                    cachedResponse = nil;
                }
                
                NSLog(@"cache url: %@ ", url);
                NSLog(@"mimeType: %@", response.MIMEType);
                // 修正一下mimeType
                if (!mimeType) {
                    mimeType = response.MIMEType;
                }
                // 检查mimeType 如果是text/html 则不缓存
//                if (![response. MIMEType isEqualToString:@"text/html"]) {
                if (![mimeType isEqualToString:@"text/html"]) {
                    // save to cache
                    // 此处otherInfo以服务端接口返回的信息为准，如果非服务端列表里的文件，则versionCode置为0，mimeType和encodingType根据response里的来
                    if (!versionCode) {
                        versionCode = @"0";
                    }
                    if (!mimeType) {
                        mimeType = response.MIMEType;
                    }
                    if (!encodingType) {
                        encodingType = response.textEncodingName;
                    }
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          //response.URL.absoluteString, @"url",
                                          [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time",
                                          versionCode, @"versionCode",
                                          mimeType, @"MIMEType",
                                          encodingType, @"textEncodingName", nil];
                    
                    [dict writeToFile:otherInfoPath atomically:YES];
                    [data writeToFile:filePath atomically:YES];
                    
                    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                }
            }
            
        }];

        return cachedResponse;
    }
    return nil;
}

- (void)readLocalFileResourceToCache:(CIBResourceInfo *)resourceInfo {
    
    NSString *url = resourceInfo.urlAddress;
    NSString *cachefileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *cachefilePath = [self cacheFilePath:cachefileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSDate *date = [NSDate date];

     NSString *localFilePath = [[NSBundle mainBundle] pathForResource:resourceInfo.fileName ofType:nil];
     NSData *localFileData = [NSData dataWithContentsOfFile:localFilePath];
    
     NSDictionary *otherInfo = [NSDictionary dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time",
         [resourceInfo mimeType], @"MIMEType",
         [resourceInfo encodingType], @"textEncodingName",
         [resourceInfo versionCode], @"versionCode",nil];
    
     [otherInfo writeToFile:otherInfoPath atomically:YES];
     [localFileData writeToFile:cachefilePath atomically:YES];
     
//     NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
//     MIMEType:[otherInfo objectForKey:@"MIMEType"]
//     expectedContentLength:bundleFileData.length
//     textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
//     
//     NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:bundleFileData];

}


@end
