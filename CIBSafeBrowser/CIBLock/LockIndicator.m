//
//  LockIndicator.m
//  
//
//  Created by CIB-Mac mini on 14-12-31.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "LockIndicator.h"

#define kBaseCircleNumber 10000       // tag基数（请勿修改）
//改动
#define kCircleDiameter 8.0            // 圆点直径
//改动
#define kCircleMargin   4.0              // 圆点间距

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LockIndicator ()
@property (nonatomic, strong) NSMutableArray* buttonArray;
@end

@implementation LockIndicator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        [self initCircles];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = YES;
        [self initCircles];
    }
    return self;
}

- (void)initCircles
{
    self.buttonArray = [NSMutableArray array];
    
    // 初始化圆点
    for (int i=0; i<9; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // 每个圆点位置
        int x = (i%3) * (kCircleDiameter+kCircleMargin);
        int y = (i/3) * (kCircleDiameter+kCircleMargin);
        
        [button setFrame:CGRectMake(x, y, kCircleDiameter, kCircleDiameter)];
        
//        [button setBackgroundColor:[UIColor clearColor]];
        button.layer.cornerRadius = 4;
        button.clipsToBounds = 4;
        [button setBackgroundColor:[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:0.3]];
        
        
//        [button setBackgroundImage:[UIImage imageNamed:@"circle_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"circle_indecator"] forState:UIControlStateSelected];
        button.userInteractionEnabled= NO;//禁止用户交互
        button.tag = i + kBaseCircleNumber + 1; // tag从基数+1开始,
        
        [self addSubview:button];
        [self.buttonArray addObject:button];
    }
    self.backgroundColor = [UIColor clearColor];
}

- (void)setPasswordString:(NSString *)string
{
    for (UIButton *button in self.buttonArray) {
        [button setSelected:NO];
    }
    
#ifdef LOCK_PWD_WITH_SEPARATOR  // 兼容老版本的string（逗号分隔）
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:string.length];
    NSArray *arr = [string componentsSeparatedByString:@","];
    for (int i=0; i < [arr count]; i++) {
        NSNumber *number = [NSNumber numberWithInt:((NSString *)arr[i]).intValue]; // 数字是0开始的
        [numbers addObject:number];
        [self.buttonArray[number.intValue] setSelected:YES];
    }
#else
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:string.length];
    for (int i=0; i<string.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSNumber *number = [NSNumber numberWithInt:[string substringWithRange:range].intValue]; // 数字是0开始的
        [numbers addObject:number];
        [self.buttonArray[number.intValue] setSelected:YES];
    }
#endif
}

@end
