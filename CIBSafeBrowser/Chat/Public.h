//
//  Public.h
//  RegisterAndLogin
//
//  Created by jiaxun1 on 15/4/1.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//@class ImageModel;
//@class AFSecurityPolicy;
@interface Public : NSObject

/**
 *  判断是否为身份证号码
 *
 *  @param value    身份证号码
 *
 *  @return 返回是，符合规定，返回否，不符合规定
 */
+ (BOOL)validateIDCardNumber:(NSString *)value;

/**
 *  判断是否有空格
 *
 *  @param value    输入
 *
 *  @return 返回是，不符合规定，返回否，符合规定
 */
+ (BOOL)isPlaceIn:(NSString *)value;

/**
 *  判断是否为11位手机号码上
 *
 *  @param mobileNum    手机号码
 *
 *  @return 返回是，手机号码符合规定，返回否，手机号码不符合规定
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

/*!
 *  @abstract 判断是否为纯数字
 *
 *  @param string 传入字符串
 *
 *  @param return 返回是，符合规定，返回否，不符合规定
 *
 *  @discussion
 *
 */
+ (BOOL)isPureInt:(NSString*)string;

/*!
 *  @abstract 判断是否为6位纯数字邮政编码
 *
 *  @param postCode 邮编
 *
 *  @param return 返回是，符合规定，返回否，不符合规定
 *
 *  @discussion
 *
 */
+ (BOOL)isPostCode:(NSString *)postCode;

/*!
 *  @abstract 判断是否为6位纯数字支付密码
 *
 *  @param passwd 支付密码
 *
 *  @param return 返回是，支付密码符合规定，返回否，支付密码不符合规定
 *
 *  @discussion
 *
 */
+ (BOOL)isPayPasswd:(NSString *)passwd;

/**
 *  判断是否为6位验证码
 *
 *  @param string    验证码
 *
 *  @return 返回是，符合规定，返回否，不符合规定
 */
+ (BOOL)isVerifyCode:(NSString *)string;

/**
 *  判断密码是否是8到15位字母加数字
 *
 *  @param passwd   密码
 *
 *  @return 返回是，密码设置符合规定，返回否，密码设置不符合规定
 */
+ (BOOL)isValidatePassword:(NSString *)passwd;

/*!
 *  @brief  根据字号计算字符串的size
 *
 *  @param string 传入字符串
 *  @param font   传入字符串的字号
 *
 *  @return 字符串size
 */
+ (CGSize)sizeOfString:(NSString *)string
              withFont:(UIFont *)font;
+ (CGSize)sizeOfString:(NSString *)string defaultSize:(CGSize)defaultSize withFont:(UIFont *)font;
+ (CGRect)rectOfString:(NSString *)string
              withFont:(UIFont *)font
           defaultSize:(CGSize)size;

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;

//图片拉伸
+ (UIImage *)imageScales:(UIImage *)sourceImage;

+ (NSString *)createUUID;

/**
 *  按照指定的格式返回日期的字符串
 *
 *  @param date    日期
 *  @param formatt 指定的字符串样式
 *
 *  @return 日期字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date formatt:(NSString *)formatt;

@end
