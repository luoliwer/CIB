//
//  NewsPage.h
//  IndustrialBank
//
//  Created by issuser on 15/9/16.
//
//

#import <UIKit/UIKit.h>
#define MCPAGERVIEW_DID_UPDATE_NOTIFICATION @"MCPageViewDidUpdate"

@protocol PagerViewDelegate;

@interface NewsPage : UIView

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,readonly) NSInteger numberOfPages;
@property (nonatomic,assign) NSInteger pattern;
@property (nonatomic,assign) id<PagerViewDelegate>delegate;


- (void) changePage:(NSInteger)page;
@end

@protocol PagerViewDelegate <NSObject>

@optional

- (void)pageViewUpdateToPage:(NSInteger)newPage;

@end