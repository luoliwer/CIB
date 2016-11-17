//
//  NewsPage.m
//  IndustrialBank
//
//  Created by issuser on 15/9/16.
//
//

#import "NewsPage.h"

@implementation NewsPage{
    NSMutableDictionary *_images;
    NSMutableArray *_pageViews;
    
}

@synthesize page = _page;
@synthesize pattern = _pattern;
@synthesize delegate = _delegate;

- (void)commonInit
{
    _page = 0;
    _images = [NSMutableDictionary dictionary];
    _pageViews = [[NSMutableArray alloc]init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) changePage:(NSInteger)page
{
    // Skip if delegate said "do not update"
    self.page=page-1;
    for(UIImageView* img in _pageViews){
        NSInteger tag = img.tag;
        if(page==tag){
            img.image=[UIImage imageNamed:@"ic_spot_c"];
        }else{
            img.image=[UIImage imageNamed:@"ic_spot"];
        }
    }
}

- (NSInteger)numberOfPages
{
    return _pattern;
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
//    self.page = [_tapViews indexOfObject:recognizer.view];
}

- (void)layoutSubviews
{
    [_pageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
    [_pageViews removeAllObjects];
    NSInteger pages = self.numberOfPages;
    CGFloat xOffset = 0;
    for (int i=0; i<pages; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 3)];
        CGRect frame = imageView.frame;
        frame.origin.x = xOffset;
        imageView.frame = frame;
        if (i == self.page) {
            UIImage* img = [UIImage imageNamed:@"ic_spot_c"];
            imageView.image=img;
        }else{
            UIImage* img = [UIImage imageNamed:@"ic_spot"];
            imageView.image=img;
        }
        imageView.tag=i+1;
        [self addSubview:imageView];
        [_pageViews addObject:imageView];
        xOffset = xOffset + frame.size.width+4;
    }
}

@end
