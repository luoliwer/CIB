//
//  GlobleData.m
//  spartacrm
//
//  Created by hunkzeng on 14-6-10.
//  Copyright (c) 2014年 vojo. All rights reserved.
//

#import "GlobleData.h"

@implementation GlobleData
+ (GlobleData *) sharedInstance {
    
    static GlobleData *sharedInstance = nil;
    static dispatch_once_t globleOnceToken;
    
    dispatch_once(&globleOnceToken, ^{
        sharedInstance = [[GlobleData alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    
    
    return self;
}


@end
