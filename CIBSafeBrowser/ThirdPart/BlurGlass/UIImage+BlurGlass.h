//
//  UIImage+BlurGlass.h
//  VoteWhere
//
//  Modified by cib on 15/1/23.
//  Created by WJ02047 mini on 14-12-9.
//  Copyright (c) 2014年 Touna Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BlurGlass)

/*
 参数:
 alpha: 透明度 0~1, 0为白, 1为深灰色
 radius: 半径:默认30, 推荐值3, 半径值越大越模糊, 值越小越清楚
 colorSaturationFactor: 色彩饱和度(浓度)因子: 0是黑白灰, 9是浓彩色, 1是原色, 默认1.8 (“彩度”，英文是称Saturation，即饱和度。将无彩色的黑白灰定为0，最鲜艳定为9s，这样大致分成十阶段，让数值和人的感官直觉一致。)
 */
- (UIImage *)imgWithLightAlpha:(CGFloat)alpha radius:(CGFloat)radius colorSaturationFactor:(CGFloat)colorSaturationFactor;
- (UIImage *)imgWithBlur;

@end