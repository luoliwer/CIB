//
//  WebSocketManager.h
//  ChatDemo
//
//  Created by YangChao on 25/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JFRWebSocket;

@interface JSSendMessageManager : NSObject

+ (instancetype)sharedManager;

- (void)sendMessage:(NSString *)message socket:(JFRWebSocket *)socket disConnectBlock:(void(^)())disBlock;

@end
