//
//  NewesCell.m
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "NewsCell.h"
#import "Message.h"
#import "Chatter.h"
#import "ChatDBManager.h"
#import "GTMBase64.h"

@implementation NewsCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconView.layer.cornerRadius = 20;
    _iconView.clipsToBounds = YES;
    
    _msgNumLb.layer.cornerRadius = 10;
    _msgNumLb.clipsToBounds = YES;
    
    
}

- (void)setMessage:(Message *)message
{
    _message = message;
    
    Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:message.msgFromerId];
    if (chat) {
        NSString *picString = chat.iconPath;
        if (picString && ![picString isEqual:[NSNull null]] && ![picString isEqualToString:@"null"] ) {
            NSData *picData = [GTMBase64 decodeString:picString];
            UIImage *image = [UIImage imageWithData:picData];
            _iconView.image = image;
        } else {
            _iconView.image = [UIImage imageNamed:@"ic_head"];
        }
    } else {
        // TODO 添加调用服务端接口，查询此用户名称及头像的逻辑
        _iconView.image = [UIImage imageNamed:@"ic_head"];
    }
    
    _newsFromer.text = message.msgFromerName;
    _newsTime.text = ([message.msgTime isEqual:[NSNull null]] ||  message.msgTime == nil) ? @"" :[message.msgTime substringWithRange:NSMakeRange(5, 11)];

    if (message.fileType == FileTypeOpenApp || message.fileType == FileTypeOpenUrl) {
        NSString *labelText = message.msgContent;
        NSError *error = nil;
        id contentJson = [NSJSONSerialization JSONObjectWithData:[labelText dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        if ([contentJson isKindOfClass:[NSDictionary class]]) {
            labelText = [contentJson objectForKey:@"title"];
        }
        if (message.fileType == FileTypeOpenApp) { // 如果是app类型的消息，可能存在content字段，若有则显示此字段
            NSString *content = [contentJson objectForKey:@"content"];
            if (content && ![content isEqualToString:@""]) {
                labelText = content;
            }
        }
        _newsContentLb.text = [NSString stringWithFormat:@"[链接] %@", labelText];
    }
    else if (message.fileType == FileTypePic) {
        _newsContentLb.text = @"[图片]";
    }
    else {
      _newsContentLb.text = message.msgContent;
    }
    
    _msgNumLb.text = [NSString stringWithFormat:@"%d", message.msgNum];
    if (message.msgNum == 0) {
        _msgNumLb.hidden = YES;
    } else {
        _msgNumLb.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
