//
//  MessageFrame.m
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "MessageFrame.h"
#import "Message.h"
#import "Public.h"

@implementation MessageFrame

- (void)setMessage:(Message *)message
{
    _message = message;
    
    //获取屏幕宽高度
    CGSize boundSize = [UIScreen mainScreen].bounds.size;
    
    //显示时间
    if (_showTime) {
        CGSize timeSize = [Public sizeOfString:_message.msgTime defaultSize:CGSizeMake(boundSize.width, CGFLOAT_MAX) withFont:kTimeFont];
        CGFloat w = timeSize.width + 2 * kTimeMarginW;
        CGFloat h = 22;
        CGFloat x = (boundSize.width - w) / 2;
        CGFloat y = kTimeTop;
        
        _msgTimeFrame = CGRectMake(x, y, w, h);
    }
    
    if (message.fileType == FileTypePic) {
        [self picLayout];
    } else if (message.fileType == FileTypeOther) {
        [self picLayout];
    } else if (message.fileType == FileTypeOpenUrl || message.fileType == FileTypeOpenApp) {
        [self urlOrAppLayout];
    }  else {
        [self textLayout];
    }
}

/**
 *  发送的消息是图片，对其进行布局
 */
- (void)picLayout
{
    //获取屏幕宽高度
    CGSize boundSize = [UIScreen mainScreen].bounds.size;
    
    //头像昵称
    CGFloat iconY = CGRectGetMaxY(_msgTimeFrame);
    if (_showName) {
        CGFloat w = 60;
        CGFloat h = 22;
        CGFloat x = kLeading;
        if (_msgType == MessageTypeMe) {
            x = boundSize.width - w - kPadding - kLeading;
        }
        CGFloat y = iconY + kTop;
        _nameFrame = CGRectMake(x, y, w, h);
        
        iconY += h;
    }
    //头像
    CGFloat iconWH = kIconWH;
    CGFloat x = kLeading;
    if (_msgType == MessageTypeMe) {
        x = boundSize.width - iconWH - kPadding - kLeading;
        iconY = CGRectGetMaxY(_msgTimeFrame);
    }
    _iconFrame = CGRectMake(x, iconY + kTop, iconWH, iconWH);
    
    //发送的图片的frame
    CGFloat contX = kLeading + kIconWH - kPadding;
    CGFloat y = CGRectGetMaxY(_msgTimeFrame) + kTop;
    CGFloat w = 120;
    CGFloat h = 160;
    if (_msgType == MessageTypeMe) {
        contX = boundSize.width - kLeading - kIconWH - w;
    }
    _msgContentFrame = CGRectMake(contX, y, w, h);
    
    _cellHeight += CGRectGetMaxY(_msgContentFrame);
}

/**
 *  发送的消息是文件，对其进行布局
 */
- (void)fileLayout
{
    //获取屏幕宽高度
    CGSize boundSize = [UIScreen mainScreen].bounds.size;
    
    //头像昵称
    CGFloat iconY = CGRectGetMaxY(_msgTimeFrame);
    if (_showName) {
        CGFloat w = 60;
        CGFloat h = 22;
        CGFloat x = kLeading;
        if (_msgType == MessageTypeMe) {
            x = boundSize.width - w - kPadding - kLeading;
        }
        CGFloat y = iconY + kTop;
        _nameFrame = CGRectMake(x, y, w, h);
        
        iconY += h;
    }
    //头像
    CGFloat iconWH = kIconWH;
    CGFloat x = kLeading;
    if (_msgType == MessageTypeMe) {
        x = boundSize.width - iconWH - kPadding - kLeading;
        iconY = CGRectGetMaxY(_msgTimeFrame);
    }
    _iconFrame = CGRectMake(x, iconY + kTop, iconWH, iconWH);
    
    //发送的图片的frame
    CGFloat contX = kLeading + kIconWH + kPadding;
    CGFloat y = CGRectGetMaxY(_msgTimeFrame) + kTop;
    CGFloat w = 90;
    CGFloat h = 120;
    if (_msgType == MessageTypeMe) {
        contX = boundSize.width - kLeading - kIconWH - w - 2 * kPadding;
    }
    _msgContentFrame = CGRectMake(contX, y, w, h);
    
    _cellHeight += CGRectGetMaxY(_msgContentFrame);
}

/**
 *  发送的消息是文字，对其进行布局
 */
- (void)textLayout
{
    //获取屏幕宽高度
    CGSize boundSize = [UIScreen mainScreen].bounds.size;
    //文本消息内容
    CGFloat sizeWidth = boundSize.width - kLeading - kPadding - kIconWH - kTrailing - kContentLeft - kContentRight;
    
    CGSize contentSize = [Public sizeOfString:_message.msgContent defaultSize:CGSizeMake(sizeWidth, CGFLOAT_MAX) withFont:kContentFont];
    CGFloat contX = kLeading + kIconWH + kPadding;
    CGFloat y = CGRectGetMaxY(_msgTimeFrame) + kTop;
    if (_msgType == MessageTypeMe) {
        contX = boundSize.width - kLeading - kIconWH - contentSize.width - 2 * kPadding - kContentRight - kContentLeft;
    }
    _msgContentFrame = CGRectMake(contX, y, contentSize.width +  kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);
    _cellHeight += CGRectGetMaxY(_msgContentFrame);
    
    //头像
    CGFloat iconWH = kIconWH;
    CGFloat x = kLeading;
    CGFloat iconY = CGRectGetMaxY(_msgContentFrame) - iconWH;
    if (_msgType == MessageTypeMe) {
        x = boundSize.width - iconWH - kPadding - kLeading;
    }
    _iconFrame = CGRectMake(x, iconY, iconWH, iconWH);
    
    if (_showName) {
        CGFloat w = 60;
        CGFloat h = 22;
        CGFloat x = kLeading;
        if (_msgType == MessageTypeMe) {
            x = boundSize.width - w - kPadding - kLeading;
        }
        CGFloat y = (CGRectGetMinY(_iconFrame) - h) < 0 ? 0 : CGRectGetMinY(_iconFrame) - h;
        _nameFrame = CGRectMake(x, y, w, h);
    }
}

/**
 *  发送的消息是url或者App，对其进行布局
 */
- (void)urlOrAppLayout
{
    //获取屏幕宽高度
    CGSize boundSize = [UIScreen mainScreen].bounds.size;
    //文本消息内容
    CGFloat sizeWidth = boundSize.width - kLeading - kPadding - kIconWH - kTrailing - kContentLeft - kContentRight;
    
    NSError *error = nil;
    NSString *title = @"未知title";
    NSString *messageContent = _message.msgContent;
    id contentJson = [NSJSONSerialization JSONObjectWithData:[messageContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if ([contentJson isKindOfClass:[NSDictionary class]]) {
        title = [contentJson objectForKey:@"title"];
    }
    if (_message.fileType == FileTypeOpenApp) { // 如果是app类型的消息，可能存在content字段，若有则显示此字段
        NSString *content = [contentJson objectForKey:@"content"];
        if (content && ![content isEqualToString:@""]) {
            title = content;
        }
    }
    CGSize contentSize = [Public sizeOfString:title defaultSize:CGSizeMake(sizeWidth, CGFLOAT_MAX) withFont:kContentFont];
    CGFloat contX = kLeading + kIconWH + kPadding;
    CGFloat y = CGRectGetMaxY(_msgTimeFrame) + kTop;
    if (_msgType == MessageTypeMe) {
        contX = boundSize.width - kLeading - kIconWH - contentSize.width - 2 * kPadding - kContentRight - kContentLeft;
    }
    _msgContentFrame = CGRectMake(contX, y, contentSize.width +  kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);
    _cellHeight += CGRectGetMaxY(_msgContentFrame);
    
    //头像
    CGFloat iconWH = kIconWH;
    CGFloat x = kLeading;
    CGFloat iconY = CGRectGetMaxY(_msgContentFrame) - iconWH;
    if (_msgType == MessageTypeMe) {
        x = boundSize.width - iconWH - kPadding - kLeading;
    }
    _iconFrame = CGRectMake(x, iconY, iconWH, iconWH);
    
    if (_showName) {
        CGFloat w = 60;
        CGFloat h = 22;
        CGFloat x = kLeading;
        if (_msgType == MessageTypeMe) {
            x = boundSize.width - w - kPadding - kLeading;
        }
        CGFloat y = (CGRectGetMinY(_iconFrame) - h) < 0 ? 0 : CGRectGetMinY(_iconFrame) - h;
        _nameFrame = CGRectMake(x, y, w, h);
    }
}

@end
