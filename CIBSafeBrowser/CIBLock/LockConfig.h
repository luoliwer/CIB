//
//  LockConfig.h
//
//
//  Created by CIB-Mac mini on 14-12-31.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef CIBSafeBrowser_LockConfig_h

#define kTipColorNormal [UIColor whiteColor]
#define kTipColorError [UIColor redColor]

//#define LockAnimationOn  // 开启窗口动画，注释此行即可关闭，目前动画还不完美

#define LOCK_MIN_PWD_LENGTH 3
#define LOCK_PWD_WITH_SEPARATOR  // 密码中是否包含分隔符（与老版本兼容），不包含时注释掉
/*
#ifdef LOCK_PWD_WITH_SEPARATOR
    // 带分隔符代码
#else
    // 不带分隔符代码
#endif
 */

#endif