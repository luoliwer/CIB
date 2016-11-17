//
//  MyUtils.h
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-8-27.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppProduct;
@class DownloadFile;
@class AppFavor;

typedef enum  {
    LinearGradientDerectionTopToBottom,  // 从上到小
    LinearGradientDerectionLeftToRight,  // 从左到右
    LinearGradientDerectionUpLeftToLowRight,  // 左上到右下
    LinearGradientDerectionUpRightToLowLeft,  // 右上到左下
} LinearGradientDerection;

@interface MyUtils : NSObject

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (NSString *)mimeType:(NSString *)filePath;  // 获取本地文件的mimetype

+ (id)propertyOfResource:(NSString *)src forKey:(NSString *)key; // 获取资源文件中的设置

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message; // 显示一个只有确定按钮的alert

+ (BOOL)isNetworkAvailable;  // 网络状态是否可用
+ (BOOL)isNetworkAvailableInView:(UIView *)view; // 网络状态是否可用(并提示)
+ (BOOL)isWifiAvailable;  // WiFi是否可用

+ (BOOL)isSystemVersionBelowEight; //系统版本是否低于8.0

+ (NSString *)MD5Digest:(NSString *)key;  // MD5摘要

/**
 *  对指定的view绘制snapshot: 屏幕截屏
 *
 *  @param view 要snapshot的view
 *
 *  @return 绘制的图片对象
 */
+ (UIImage *)screenShotFromView:(UIView *)view;

/**
 *  绘制一张指定大小的颜色线性渐变图片
 *
 *  @param colors 渐变颜色列表，非空，可多个，建议颜色设置为2个相近色为佳，设置3个相近色能形成拟物化的凸起感
 *  @param locations 颜色所在位置（范围0~1），数组的个数不小于colors中存放颜色的个数，置为NULL时相当于第一个颜色是0，最后一个颜色是1，中间颜色平分
 *  @param gradientType 渐变方向
 *  @param size 图片尺寸
 *
 *  @return 绘制的图片对象
 */
+ (UIImage *) drawLinearGradientImageFromColors:(NSArray*)colors
                                      locations:(const CGFloat [])locations
                                   gradientType:(LinearGradientDerection)gradientDerection
                                           size:(CGSize)size;

/**
 *  绘制一张指定大小的颜色线性渐变图片
 *
 *  @param colors 渐变颜色列表，非空，可多个，建议颜色设置为2个相近色为佳，设置3个相近色能形成拟物化的凸起感
 *  @param locations 颜色所在位置（范围0~1），数组的个数不小于colors中存放颜色的个数，置为NULL时相当于第一个颜色是0，最后一个颜色是1，中间颜色平分
 *  @param start 起始位置（相对于生成的图片）
 *  @param end 终止位置（相对于生成的图片）
 *  @param size 图片尺寸
 *
 *  @return 绘制的图片对象
 */
+ (UIImage*) drawLinearGradientImageFromColors:(NSArray *)colors
                                     locations:(const CGFloat [])locations
                                    startPoint:(CGPoint)start
                                      endPoint:(CGPoint)end
                                          size:(CGSize)size;

/**
 *  绘制一张指定大小的颜色径向渐变图片
 *
 *  @param colors 渐变颜色列表，非空，可多个
 *  @param locations 颜色所在位置（范围0~1），数组的个数不小于colors中存放颜色的个数，置为NULL时相当于第一个颜色是0，最后一个颜色是1，中间颜色平分
 *  @param start 起始点位置（相对于生成的图片）
 *  @startRadius:起始半径（通常为0，否则在此半径范围内容无任何填充）
 *  @param end 终点位置（通常和起始点相同，否则会有偏移）
 *  @param endRadius:终点半径（也就是渐变的扩散长度）
 *  @param size 图片尺寸
 *
 *  @return 绘制的图片对象
 */
+ (UIImage*) drawRadialGradientImageFromColors:(NSArray *)colors
                                     locations:(const CGFloat [])locations
                                   startCenter:(CGPoint)start
                                   startRadius:(CGFloat)startRadius
                                     endCenter:(CGPoint)end
                                     endRadius:(CGFloat)endRadius
                                          size:(CGSize)size;

/**
 *  UIColor转UIImage
 *
 *  @param color 转的颜色
 *
 *  @return 绘制的图片对象
 */
+ (UIImage*)createImageWithColor: (UIColor*)color;

/**
 *  拼接URL地址（主要应对前半部分结尾和后半部分开头的斜杠问题）
 *
 *  @param baseURL     URL地址前半段
 *  @param relativeURL URL地址后半段
 *
 *  @return 拼接后的URL
 */
+ (NSString *)combineURLWithBaseURL:(NSString *)baseURL
                     andRelativeURL:(NSString *)relativeURL;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message autoHideAfterSeconds:(int)second;

+ (void)loadCACertificateSuccess:(void(^)(NSString *responseCode, NSString *responseInfo))success failure:(void(^)(NSString *responseCode, NSString *responseInfo))failure;

+ (void)openUrl:(NSString *)url ofApp:(AppProduct *)app;

+ (void)openFile:(DownloadFile *)file;

+(AppProduct*) getProductFromList:(NSArray*) array withAppName:(NSString*) appName;
+(AppFavor*) getFavorFromList:(NSArray*) array withAppName:(NSString*) appName;

@end
