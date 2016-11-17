//
//  Public.m
//  RegisterAndLogin
//
//  Created by jiaxun1 on 15/4/1.
//
//

#import "Public.h"
//#import "AppDelegate.h"
//#import "AFSecurityPolicy.h"

@implementation Public

/*
 *  判断是否为身份证号码
 *
 *  @param value    身份证号码
 *
 *  @return 返回是，符合规定，返回否，不符合规定
 */
+ (BOOL)validateIDCardNumber:(NSString *)value {
    
    BOOL retValue = NO;
    
    if (value.length > 0) {
        NSInteger length = value.length;
        if (length == 15 || length == 18) {
            if ([Public isPureInt:[value substringWithRange:NSMakeRange(0, length - 2)]]) {
                retValue = YES;
            } else {
                retValue = NO;
            }
        } else {
            retValue = NO;
        }
    }
    
    return retValue;
}

/**
 *  判断是否有空格
 *
 *  @param value    输入
 *
 *  @return 返回是，不符合规定，返回否，符合规定
 */
+ (BOOL)isPlaceIn:(NSString *)value {
    BOOL retValue = NO;
    
    if (value.length > 0) {
        if ([value rangeOfString:@" "].location > 0) {
            retValue = YES;
        }else{
            retValue = NO;
        }
    }else{
        retValue = NO;
    }
    return retValue;
}

/**
 *  判断是否为11位手机号码上
 *
 *  @param mobileNum    手机号码
 *
 *  @return 返回是，手机号码符合规定，返回否，手机号码不符合规定
 */

+ (BOOL)isMobileNumber:(NSString *)mobileNum {
    BOOL retValue = NO;
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[0235-9])\\d{8}$";
    /**
    * 中国移动：China Mobile
    * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
    */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
    * 中国联通：China Unicom
    * 130,131,132,152,155,156,185,186
    */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
    * 中国电信：China Telecom
    * 133,1349,153,180,189
    */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
    * 大陆地区固话及小灵通
    * 区号：010,020,021,022,023,024,025,027,028,029
    * 号码：七位或八位
    */
//     NSString * PHS = @"^0(10-|2[0-5789]-|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];

    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
//        || [regextestphs evaluateWithObject:mobileNum] == YES
        )
        {
            retValue = YES;
        }
    else
        {
            retValue = NO;
        }
    return retValue;
}

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
+ (BOOL)isPureInt:(NSString*)string {
    
    BOOL retValue = NO;
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    retValue = [scan scanInt:&val] && [scan isAtEnd];
    
    return retValue;
}

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
+ (BOOL)isPostCode:(NSString *)postCode {
    
    BOOL retValue = NO;
    do {
        // 检查长度是否为11
        if (postCode.length != 6) {
            break;
        }
        // 检查是否为纯数字
        if (![self isPureInt:postCode]) {
            break;
        }
        retValue = YES;
    } while (0);
    
    return retValue;
}

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
+ (BOOL)isPayPasswd:(NSString *)passwd {
    
    BOOL retValue = NO;
    do {
        // 检查长度是否为11
        if (passwd.length != 6) {
            break;
        }
        // 检查是否为纯数字
        if (![self isPureInt:passwd]) {
            break;
        }
        retValue = YES;
    } while (0);
    
    return retValue;
}

/**
 *  判断是否为6位验证码
 *
 *  @param string    验证码
 *
 *  @return 返回是，符合规定，返回否，不符合规定
 */
+ (BOOL)isVerifyCode:(NSString *)string {
    BOOL retValue = NO;
    if (string.length > 0) {
        do {
            if (![self isPureInt:string]) {
                break;
            }
            if (string.length != 6) {
                break;
            }
            retValue = YES;
        } while (0);
    }
    
    return retValue;
}

/**
 *  判断密码是否是8到15位字母加数字
 *
 *  @param passwd   密码
 *
 *  @return 返回是，密码设置符合规定，返回否，密码设置不符合规定
 */
+ (BOOL)isValidatePassword:(NSString *)passwd {
    NSString *passWordRegex = @"^[a-zA-Z0-9]{8,15}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    BOOL ret = [passWordPredicate evaluateWithObject:passwd];
    
    if (ret) {
        //數字條件
        NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
        
        //符合數字條件的有幾個字元
        NSInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:passwd
                                                                          options:NSMatchingReportProgress
                                                                            range:NSMakeRange(0, passwd.length)];
        
        //英文字條件
        NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
        
        //符合英文字條件的有幾個字元
        NSInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:passwd options:NSMatchingReportProgress range:NSMakeRange(0, passwd.length)];
        
        if (!tNumMatchCount || !tLetterMatchCount) {
            ret = NO;
        }
    }
    return ret;
}

+ (CGSize)sizeOfString:(NSString *)string
              withFont:(UIFont *)font {
    
    return [self sizeOfString:string defaultSize:CGSizeZero withFont:font];
}

+ (CGSize)sizeOfString:(NSString *)string defaultSize:(CGSize)defaultSize withFont:(UIFont *)font{
    CGSize size = CGSizeZero;
    
    // 检查参数
    if (string.length == 0 || string == nil || ![string isKindOfClass:[NSString class]])
    {
        return size;
    }
    
    if (font == nil || ![font isKindOfClass:[UIFont class]])
    {
        return size;
    }
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    size = [[[NSAttributedString alloc] initWithString:string attributes:attributes] size];
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    if (CGSizeEqualToSize(defaultSize, CGSizeZero)) {
        size = attributeString.size;
    }else{
        size = [attributeString boundingRectWithSize:defaultSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    }
    return size;
}

+ (CGRect)rectOfString:(NSString *)string
              withFont:(UIFont *)font
           defaultSize:(CGSize)size
{
    return [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
}

+ (UIImage *)drawNewImage:(UIImage *)oldImage withOldImageRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));//clear background
    [oldImage drawInRect:rect];
     UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newimage;
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//+ (AFSecurityPolicy *)customSecurityPolicy
//{
//    /**** SSL Pinning ****/
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"communityFinancial" ofType:@"der"];
//    if (cerPath == nil) {
//        NSLog(@"***文件路径没找到");
//    }
//    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    //  自签名证书设为YES 生产X.509证书设置为NO
//    [securityPolicy setAllowInvalidCertificates:YES];
//    [securityPolicy setPinnedCertificates:@[certData]];
//    /**** SSL Pinning ****/
//    
//    return securityPolicy;
//}

//图片拉伸
+ (UIImage *)imageScales:(UIImage *)sourceImage
{
    UIImage *destinationImage = nil;
    
    CGFloat t = sourceImage.size.height / 2 - 0.5;
    CGFloat b = sourceImage.size.height / 2 + 0.5;
    CGFloat l = sourceImage.size.width / 2 - 0.5;
    CGFloat r = sourceImage.size.width / 2 + 0.5;
    
    UIImage *temp = [sourceImage resizableImageWithCapInsets:UIEdgeInsetsMake(t, l, b, r) resizingMode:UIImageResizingModeStretch];
    destinationImage = temp;
    
    return destinationImage;
}

+ (NSString *)createUUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_string_ref);
    
    return uuid;
}

/**
 *  按照指定的格式返回日期的字符串
 *
 *  @param date    日期
 *  @param formatt 指定的字符串样式
 *
 *  @return 日期字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date formatt:(NSString *)formatt
{
    NSString *dateString = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatt];
    
    dateString = [formatter stringFromDate:date];
    
    return dateString;
}

@end
