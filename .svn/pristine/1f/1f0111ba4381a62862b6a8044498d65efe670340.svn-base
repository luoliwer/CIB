//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define IS_iPad  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad



@interface EGORefreshTableHeaderView (Private)

- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _frame = frame;
		self.backgroundColor = UIColorFromRGB(0xf1f2f6);
        self.translatesAutoresizingMaskIntoConstraints=NO;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:14.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
        CGRect rect = [UIScreen mainScreen].bounds;
        CGSize size = rect.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        if (width == 320) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, _frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.textColor = UIColorFromRGB(0x929899);
            label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            [self addSubview:label];
            _statusLabel=label;
            
            _layer = [CALayer layer];
            _layer.frame = CGRectMake(20.0f, frame.size.height - 48.0f, 20.0f, 20.0f);
            _layer.contentsGravity = kCAGravityResizeAspect;
            
            _layer.contents = (id)[UIImage imageNamed:@"pullRefresh"].CGImage;

        }else if (width == 375){
            label = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, _frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.textColor = UIColorFromRGB(0x929899);
            label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            [self addSubview:label];
            _statusLabel=label;
            _layer = [CALayer layer];
            _layer.frame = CGRectMake(45.0f, frame.size.height - 48.0f, 20.0f, 20.0f);
            _layer.contentsGravity = kCAGravityResizeAspect;
            
            _layer.contents = (id)[UIImage imageNamed:@"pullRefresh"].CGImage;

        }else if(width == 414){
            
		label = [[UILabel alloc] initWithFrame:CGRectMake(87.0f, _frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
        NSLog(@"center.x = %f",self.center.x);
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:14.0f];
		label.textColor = UIColorFromRGB(0x929899);
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentLeft;
		[self addSubview:label];
        _statusLabel=label;
        _layer = [CALayer layer];
        _layer.frame = CGRectMake(57.0f, frame.size.height - 48.0f, 20.0f, 20.0f);
            NSLog(@"self.width = %f",self.frame.size.width);
        _layer.contentsGravity = kCAGravityResizeAspect;
        _layer.contents = (id)[UIImage imageNamed:@"pullRefresh"].CGImage;
        }
        else if (IS_iPad){
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(267.0f, _frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
            NSLog(@"center.x = %f",self.center.x);
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.textColor = UIColorFromRGB(0x929899);
            label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            [self addSubview:label];
            _statusLabel=label;
            _layer = [CALayer layer];
            _layer.frame = CGRectMake(width / 2.0 - 140, frame.size.height - 48.0f, 20.0f, 20.0f);
            NSLog(@"self.width = %f",self.frame.size.width);
            _layer.contentsGravity = kCAGravityResizeAspect;
            _layer.contents = (id)[UIImage imageNamed:@"pullRefresh"].CGImage;
        }
    
		
       
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			_layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:_layer];
		_arrowImage=_layer;
        if (width == 320) {
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            view.frame = CGRectMake(20.0f, frame.size.height - 48.0f, 20.0f, 20.0f);
            [self addSubview:view];
            _activityView = view;
        }else if (width == 375){
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            view.frame = CGRectMake(45.0f, frame.size.height - 48.0f, 20.0f, 20.0f);
            [self addSubview:view];
            _activityView = view;
        }else if (width == 414){
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            view.frame = CGRectMake(57.0f, frame.size.height - 48.0f, 20.0f, 20.0f);
            [self addSubview:view];
            _activityView = view;
        }else if (IS_iPad){
            if (width > height) {
                UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                view.frame = CGRectMake(width / 2.0 + 200, frame.size.height - 38.0f, 0.0, 0.0);
                
                [self addSubview:view];
                _activityView =  view;
            }else{
                UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                view.frame = CGRectMake(width / 2.0 - 140, frame.size.height - 38.0f, 0.0, 0.0);
                [self addSubview:view];
                _activityView =  view;
            }
        }
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([(NSObject *)_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
//		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
//		
//		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//		[formatter setAMSymbol:@"AM"];
//		[formatter setPMSymbol:@"PM"];
//		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
//		_lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新: %@", [formatter stringFromDate:date]];
//		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}

}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"下拉刷新", @"Release to refresh status");
//			[CATransaction begin];
//			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
//			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
//			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
                
                
//				[CATransaction begin];
//				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
//				_arrowImage.transform = CATransform3DIdentity;
//				[CATransaction commit];
			}
			_layer.contents = (id)[UIImage imageNamed:@"pullRefresh"].CGImage;
			_statusLabel.text = NSLocalizedString(@"下拉刷新", @"Pull down to refresh status");
			[_activityView stopAnimating];
            
			[CATransaction begin];
            
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

			_arrowImage.hidden = NO;
            
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"下拉刷新", @"Loading Status");
			[_activityView startAnimating];
            _layer.contents = (id)[UIImage imageNamed:@"stopRefresh"].CGImage;
            _arrowImage.hidden = YES;
//			[CATransaction begin];
//			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
//			_arrowImage.hidden = YES;
//			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == EGOOPullRefreshLoading) {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([(NSObject *)_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {

    BOOL _loading = NO;
    if ([(NSObject *)_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
        
        if ([(NSObject *)_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        
        [self setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }

		
}


- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];

}
#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;

}


@end
