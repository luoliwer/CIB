//
//  GroupIconCell.m
//  CIBSafeBrowser
//
//  Created by YangChao on 29/1/16.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "GroupIconCell.h"
#import "UIImageView+WebCache.h"
#import "Chatter.h"
#import "GTMBase64.h"

@implementation GroupIconCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 初始化时加载GroupIconCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"GroupIconCell" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionViewCell类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
        _icon.layer.cornerRadius = 35;
        _icon.clipsToBounds = YES;
        _icon.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

//删除事件
- (IBAction)del:(id)sender
{
    if (_DeleteGroupMember) {
        _DeleteGroupMember(_chatter);
    }
}

- (void)setChatter:(Chatter *)chatter
{
    _chatter = chatter;
    
    self.nickName.text = chatter.chatterName ? : @"";
    
    NSString *iconPath = chatter.iconPath;
    if (iconPath == nil || [iconPath isEqual:[NSNull null]] || [iconPath isEqualToString:@"null"]) {
        iconPath = @"";
    }
    
    if (iconPath && ![iconPath isEqualToString:@""]) {
        NSString *picString = chatter.iconPath;
        NSData *picData = [GTMBase64 decodeString:picString];
        UIImage *image = [UIImage imageWithData:picData];
        _icon.image = image;
    } else {
        _icon.image = [UIImage imageNamed:@"ic_head"];
    }
}

@end
