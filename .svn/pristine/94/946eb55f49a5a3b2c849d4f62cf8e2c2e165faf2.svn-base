//
//  MessageCell.m
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "MessageCell.h"
#import "MessageFrame.h"
#import "Message.h"
#import "Public.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "CoreDataManager.h"
#import "ChatDBManager.h"
#import "Chatter.h"
#import "GTMBase64.h"
#import <CIBBaseSDK/AppInfoManager.h>

@interface MessageCell ()
{
    UIButton     *_timeBtn;
    UILabel     *_nameLb;
    UIImageView *_iconView;
    UIButton    *_contentBtn;
}
@end

@implementation MessageCell

- (void)awakeFromNib {
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self config];
    }
    return self;
}

- (void) config
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor whiteColor];
    // 1、创建时间按钮
    _timeBtn = [[UIButton alloc] init];
    [_timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _timeBtn.titleLabel.font = kTimeFont;
    _timeBtn.backgroundColor = [UIColor colorWithRed:182/255.0 green:192/255.0 blue:194/255.0 alpha:1.0];
    _timeBtn.enabled = NO;
    _timeBtn.layer.cornerRadius = 4.f;
    _timeBtn.layer.masksToBounds = YES;
    [self.contentView addSubview:_timeBtn];
    
    _nameLb = [[UILabel alloc] init];
    _nameLb.textColor = [UIColor grayColor];
    _nameLb.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:_nameLb];
    
    // 2、创建头像
    _iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_iconView];
    
    // 3、创建内容
    _contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _contentBtn.titleLabel.font = kContentFont;
    _contentBtn.titleLabel.numberOfLines = 0;
    _contentBtn.clipsToBounds = YES;
    [_contentBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_contentBtn];
}

- (void)setMsgFrame:(MessageFrame *)msgFrame
{
    _msgFrame = msgFrame;
    Message *msg = _msgFrame.message;
    
    // 1、设置时间
    [_timeBtn setTitle:msg.msgTime forState:UIControlStateNormal];
    _timeBtn.frame = _msgFrame.msgTimeFrame;
    if (!_msgFrame.showTime) {
        _timeBtn.hidden = YES;
    } else {
        _timeBtn.hidden = NO;
    }
    
    _nameLb.text = msg.msgFromerName;
    _nameLb.frame = _msgFrame.nameFrame;
    if (!_msgFrame.showName || _msgFrame.msgType == MessageTypeMe) {
        _nameLb.hidden = YES;
    } else {
        _nameLb.hidden = NO;
    }
    if (_msgFrame.msgType == MessageTypeMe) {
        _nameLb.textAlignment = NSTextAlignmentRight;
    } else {
        _nameLb.textAlignment = NSTextAlignmentLeft;
    }
    
    // 2、设置头像
    _iconView.frame = _msgFrame.iconFrame;
    CGFloat width = _msgFrame.iconFrame.size.width;
    _iconView.layer.cornerRadius = width/2;
    _iconView.contentMode = UIViewContentModeScaleToFill;
    _iconView.clipsToBounds = YES;
    if (_msgFrame.msgType == MessageTypeMe) {
        NSString *ID = [AppInfoManager getUserName];
        Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:ID];
        if (chat) {
            NSString *picString = chat.iconPath;
            if (picString && ![picString isEqual:[NSNull null]]&& ![picString isEqualToString:@"null"] ) {
                NSData *picData = [GTMBase64 decodeString:picString];
                UIImage *image = [UIImage imageWithData:picData];
                _iconView.image = image;
            } else {
                _iconView.image = [UIImage imageNamed:@"ic_head"];
            }
        } else {
            _iconView.image = [UIImage imageNamed:@"ic_head"];
        }
    } else {
        Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:msg.msgFromerId];
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
            _iconView.image = [UIImage imageNamed:@"ic_head"];
        }
    }
    
    // 3、设置内容
    if (msg.fileType == FileTypePic) {
        [_contentBtn setTitle:@"" forState:UIControlStateNormal];
        _contentBtn.frame = _msgFrame.msgContentFrame;
        _contentBtn.layer.cornerRadius = 4;
        _contentBtn.layer.borderColor = [[UIColor grayColor] CGColor];
        _contentBtn.layer.borderWidth = 0.5;
        
        UIImage *image = [self localImage:msg.msgContent];
        if (image == nil) {
            [_contentBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:msg.msgContent] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo"]];
        } else {
            [_contentBtn setBackgroundImage:image forState:UIControlStateNormal];
        }
        
        if (msg.sendPicImage) {
            [_contentBtn setBackgroundImage:msg.sendPicImage forState:UIControlStateNormal];
        } else {
            
        }
    } else if (msg.fileType == FileTypeOther) {
        [_contentBtn setTitle:@"" forState:UIControlStateNormal];
        _contentBtn.frame = _msgFrame.msgContentFrame;
        _contentBtn.layer.cornerRadius = 4;
        _contentBtn.layer.borderColor = [[UIColor grayColor] CGColor];
        _contentBtn.layer.borderWidth = 0.5;
        
        UIImage *image = [self localImage:msg.msgContent];
        if (image == nil) {
            [_contentBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:msg.msgContent] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo"]];
        } else {
            [_contentBtn setBackgroundImage:image forState:UIControlStateNormal];
        }
        
        if (msg.sendPicImage) {
            [_contentBtn setBackgroundImage:msg.sendPicImage forState:UIControlStateNormal];
        } else {
            
        }
    } else if (msg.fileType == FileTypeText){
        _contentBtn.layer.borderWidth = 0;
        [_contentBtn setTitle:msg.msgContent forState:UIControlStateNormal];
        
        _contentBtn.frame = _msgFrame.msgContentFrame;
        if (_msgFrame.msgType == MessageTypeMe) {
            _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentLeft, kContentBottom, kContentRight);
            UIImage *img = [UIImage imageNamed:@"ic_talk-blue"];
            [_contentBtn setBackgroundImage:[Public imageScales:img] forState:UIControlStateNormal];
        } else {
            _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentRight, kContentBottom, kContentLeft);
            UIImage *imgO = [UIImage imageNamed:@"talk"];
            [_contentBtn setBackgroundImage:[Public imageScales:imgO] forState:UIControlStateNormal];
        }
    }
    else if (msg.fileType == FileTypeOpenUrl || msg.fileType == FileTypeOpenApp) {
        NSError *error = nil;
        NSString *title = @"未知title";
        NSString *messageContent = msg.msgContent;
        id contentJson = [NSJSONSerialization JSONObjectWithData:[messageContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        if ([contentJson isKindOfClass:[NSDictionary class]]) {
            title = [contentJson objectForKey:@"title"];
        }
        if (msg.fileType == FileTypeOpenApp) { // 如果是app类型的消息，可能存在content字段，若有则显示此字段
            NSString *content = [contentJson objectForKey:@"content"];
            if (content && ![content isEqualToString:@""]) {
                title = content;
            }
        }
        _contentBtn.layer.borderWidth = 0;
        NSMutableAttributedString *attriContent = [[NSMutableAttributedString alloc] initWithString:title];
        [attriContent addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, title.length)];
        [attriContent addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, title.length)];
        [_contentBtn setAttributedTitle:attriContent forState:UIControlStateNormal];
        
        _contentBtn.frame = _msgFrame.msgContentFrame;
        if (_msgFrame.msgType == MessageTypeMe) {
            _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentLeft, kContentBottom, kContentRight);
            UIImage *img = [UIImage imageNamed:@"ic_talk-blue"];
            [_contentBtn setBackgroundImage:[Public imageScales:img] forState:UIControlStateNormal];
        } else {
            _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentRight, kContentBottom, kContentLeft);
            UIImage *imgO = [UIImage imageNamed:@"talk"];
            [_contentBtn setBackgroundImage:[Public imageScales:imgO] forState:UIControlStateNormal];
        }
    }
    
    else  {
        
    }
}

//从本地查找图片
- (UIImage *)localImage:(NSString *)filePath
{
    UIImage *image = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *shotFileName = filePath;
    if (range.location != NSNotFound) {
        shotFileName = [filePath substringFromIndex:range.location];
    }
    NSString *path = [[paths firstObject] stringByAppendingFormat:@"%@", shotFileName];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (isExist) {
        image = [UIImage imageWithContentsOfFile:path];
    }
    
    return image;
}

- (void)click
{
    if (_msgFrame.message.fileType == FileTypePic && _ViewPic) {
        UIImage *image =  _contentBtn.currentBackgroundImage;
        _ViewOriginalImage(image);
    }
    else if (_msgFrame.message.fileType == FileTypeOpenUrl && _OpenUrlInNewView) {
        NSString *msgContent = _msgFrame.message.msgContent;
        NSError *error = nil;
        id contentJson = [NSJSONSerialization JSONObjectWithData:[msgContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        if ([contentJson isKindOfClass:[NSDictionary class]]) {
            NSString *url = [contentJson objectForKey:@"url"];
            NSString *appName = [contentJson objectForKey:@"appname"];
            CoreDataManager *manager = [[CoreDataManager alloc] init];
            AppProduct *app = [manager getAppProductByAppName:appName];
            NSString *appNo = [app.appNo stringValue];
            _OpenUrlInNewView(url, appNo);
        }
    }
    else if (_msgFrame.message.fileType == FileTypeOpenApp && _OpenAppInNewTab) {
        NSString *msgContent = _msgFrame.message.msgContent;
        id contentJson = [NSJSONSerialization JSONObjectWithData:[msgContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        if ([contentJson isKindOfClass:[NSDictionary class]]) {
            NSString *appName = [contentJson objectForKey:@"appname"];
            CoreDataManager *manager = [[CoreDataManager alloc] init];
            AppProduct *app = [manager getAppProductByAppName:appName];
            NSString *appNo = [app.appNo stringValue];
            _OpenAppInNewTab(appNo);
        }
    }
}

//- (void)setSendPercent:(NSString *)sendPercent
//{
//    _sendPercent = sendPercent;
//    
//    if ([sendPercent isEqualToString:@"100%"]) {
//        [_contentBtn setTitle:@"" forState:UIControlStateNormal];
//    } else {
//        [_contentBtn setTitle:sendPercent forState:UIControlStateNormal];
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
