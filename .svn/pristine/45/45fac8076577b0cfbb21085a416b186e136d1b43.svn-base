//
//  CIBSideViewController.m
//
//  实现侧边菜单效果
//
//  Created by cib on 14/12/31.
//  Copyright (c) 2014年 cib. All rights reserved.
//
//  代码借鉴了Vito Modena的单侧侧边栏示例，特此感谢
//

#import "CIBSideViewController.h"

#import "Config.h"

static CGFloat kCIBSideViewControllerMenuViewDepth = 260.0f;
static CGFloat kCIBSideViewControllerTriggerDepth = 60.0f;  // 触发深度（从距侧边Depth距离内开始拖拽有效）
static const CGFloat kCIBSideViewControllerMenuViewInitialOffset = -60.0f;
static const NSTimeInterval kCIBSideViewControllerAnimationDuration = 0.5;
static const CGFloat kCIBSideViewControllerOpeningAnimationSpringDamping = 0.7f;
static const CGFloat kCIBSideViewControllerOpeningAnimationSpringInitialVelocity = 0.1f;
static const CGFloat kCIBSideViewControllerClosingAnimationSpringDamping = 1.0f;
static const CGFloat kCIBSideViewControllerClosingAnimationSpringInitialVelocity = 0.5f;

typedef NS_ENUM(NSUInteger, CIBSideViewControllerState)
{
    CIBSideViewControllerStateClosed = 0,
    CIBSideViewControllerStateOpening,
    CIBSideViewControllerStateOpen,
    CIBSideViewControllerStateClosing
};

@interface CIBSideViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong, readwrite) UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *menuViewController;
@property(nonatomic, strong, readwrite) UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *contentViewController;

@property(nonatomic, strong) UIView *menuView;
@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, assign) CGPoint panGestureStartLocation;
@property(nonatomic, assign) BOOL isPanGestureControllEnable;

@property(nonatomic, assign) CIBSideViewControllerState sideViewState;

@end


@implementation CIBSideViewController

- (id)initWithMenuViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)menuViewController
           contentViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)contentViewController {
    
    NSParameterAssert(menuViewController);
    NSParameterAssert(contentViewController);
    
    self = [super init];
    if (self) {
        self.menuViewController = menuViewController;
        self.contentViewController = contentViewController;
        
        // 默认整个容器view的背景色与菜单背景色一致，防止出现黑底
        [self.view setBackgroundColor:[menuViewController.view backgroundColor]];
        
        // 设置子controller中的sideView引用
        if ([self.menuViewController respondsToSelector:@selector(setSideView:)]) {
            self.menuViewController.sideView = self;
        }
        if ([self.contentViewController respondsToSelector:@selector(setSideView:)]) {
            self.contentViewController.sideView = self;
        }
        
        // 默认菜单在左侧
        self.derection = CIBSideViewControllerDirectionLeft;
    }
    
    return self;
}

- (id)initWithMenuViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)menuViewController
           contentViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)contentViewController
                   menuViewDepth:(CGFloat)depth {
    NSParameterAssert(menuViewController);
    NSParameterAssert(contentViewController);
    NSParameterAssert(depth > 0);
    
    self = [super init];
    if (self) {
        self.menuViewController = menuViewController;
        self.contentViewController = contentViewController;
        
        // 默认整个容器view的背景色与菜单背景色一致，防止出现黑底
        [self.view setBackgroundColor:[menuViewController.view backgroundColor]];
        
        // 设置子controller中的sideView引用
        if ([self.menuViewController respondsToSelector:@selector(setSideView:)]) {
            self.menuViewController.sideView = self;
        }
        if ([self.contentViewController respondsToSelector:@selector(setSideView:)]) {
            self.contentViewController.sideView = self;
        }
        
        // 默认菜单在左侧
        self.derection = CIBSideViewControllerDirectionLeft;
        kCIBSideViewControllerMenuViewDepth = depth;
    }
    
    return self;
}

- (void)setPanGestureControllEnable:(BOOL)enable {
    if (!self.isPanGestureControllEnable && enable) {
        [self.contentView addGestureRecognizer:self.panGestureRecognizer];
        self.isPanGestureControllEnable = YES;
    }
    else if(self.isPanGestureControllEnable && !enable) {
        [self.contentView removeGestureRecognizer:self.panGestureRecognizer];
        self.isPanGestureControllEnable = NO;
    }
}

- (void)setPanGestureControllEnable:(BOOL)enable triggerDepth:(CGFloat)depth {
    [self setPanGestureControllEnable:enable];
    kCIBSideViewControllerTriggerDepth = depth;
}

/**
 设置content区域为content controller
 */
- (void)addContentViewController {
    NSParameterAssert(self.contentViewController);
    NSParameterAssert(self.contentView);
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentView addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
}

#pragma mark - Managing the view
// 是否支持转屏
- (BOOL)shouldAutorotate {
    return YES;
}
// 支持的屏幕方向
- (NSUInteger)supportedInterfaceOrientations {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        return UIInterfaceOrientationMaskAll;
    }
    else {  // iPhone&iPod
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // 初始化menu和content view的containers
    self.menuView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.menuView.autoresizingMask = self.view.autoresizingMask;
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.autoresizingMask = self.view.autoresizingMask;
    // 增加一条menu和content间的分界线
    self.contentView.layer.shadowOffset = CGSizeZero;
    self.contentView.layer.shadowOpacity = 0.7f;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds];
    self.contentView.layer.shadowPath = shadowPath.CGPath;
    
    // 添加content view的container
    [self.view addSubview:self.contentView];

    // 添加content view controller到container中
    [self addContentViewController];

    // 设置手势
    [self setupGestureRecognizers];
}

#pragma mark - Configuring the view’s layout behavior

- (UIViewController *)childViewControllerForStatusBarHidden {
    NSParameterAssert(self.menuViewController);
    NSParameterAssert(self.contentViewController);
    
    if (self.sideViewState == CIBSideViewControllerStateOpening) {
        return self.menuViewController;
    }
    return self.contentViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    NSParameterAssert(self.menuViewController);
    NSParameterAssert(self.contentViewController);
    
    if (self.sideViewState == CIBSideViewControllerStateOpening) {
        return self.menuViewController;
    }
    return self.contentViewController;
}

#pragma mark - Gesture recognizers

- (void)setupGestureRecognizers {
    NSParameterAssert(self.contentView);
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    
    [self.contentView addGestureRecognizer:self.panGestureRecognizer];
    self.isPanGestureControllEnable = YES;
}

- (void)addClosingGestureRecognizers {
    NSParameterAssert(self.contentView);
    NSParameterAssert(self.panGestureRecognizer);
    
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)removeClosingGestureRecognizers {
    NSParameterAssert(self.contentView);
    NSParameterAssert(self.panGestureRecognizer);

    [self.contentView removeGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark Tap关闭侧边菜单
- (void)tapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self close];
    }
}

#pragma mark Pan打开/关闭侧边菜单
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSParameterAssert([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]);
    
    if (self.sideViewState == CIBSideViewControllerStateClosed) {  // 只有在侧边开始滑动才能打开
        CGPoint location = [(UIPanGestureRecognizer *)gestureRecognizer locationInView:self.view];
        if (self.derection == CIBSideViewControllerDirectionLeft && location.x > kCIBSideViewControllerTriggerDepth) {
            return NO;
        }
        else if (self.derection != CIBSideViewControllerDirectionLeft
                 && location.x < self.view.bounds.size.width - kCIBSideViewControllerTriggerDepth) { // 非左即右
            return NO;
        }
    }
    
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
    if (self.derection == CIBSideViewControllerDirectionLeft) {  // 菜单在左侧时，向右拖拽打开菜单，向左拖拽关闭菜单
        if (self.sideViewState == CIBSideViewControllerStateClosed && velocity.x > 0.0f) {
            return YES;
        }
        else if (self.sideViewState == CIBSideViewControllerStateOpen && velocity.x < 0.0f) {
            return YES;
        }
    }
    else {  // 非左即右，菜单在右侧，向左拖拽打开菜单，向右拖拽关闭菜单
        if (self.sideViewState == CIBSideViewControllerStateClosed && velocity.x < 0.0f) {
            return YES;
        }
        else if (self.sideViewState == CIBSideViewControllerStateOpen && velocity.x > 0.0f) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer {
    NSParameterAssert(self.menuView);
    NSParameterAssert(self.contentView);
    
    UIGestureRecognizerState state = panGestureRecognizer.state;
    CGPoint location = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    int deflection = 1;  // 偏转值，用于修正左右不同方向的计算
    if (self.derection != CIBSideViewControllerDirectionLeft) { // 非左即右
        deflection *= -1;
    }
    
    switch (state) {

        case UIGestureRecognizerStateBegan:
            self.panGestureStartLocation = location;
            if (self.sideViewState == CIBSideViewControllerStateClosed) {
                [self willOpen];
            }
            else {
                [self willClose];
            }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat delta = 0.0f;
            if (self.sideViewState == CIBSideViewControllerStateOpening) {
                delta = (location.x - self.panGestureStartLocation.x) * deflection;
            }
            else if (self.sideViewState == CIBSideViewControllerStateClosing) {
                delta = kCIBSideViewControllerMenuViewDepth - (self.panGestureStartLocation.x - location.x) * deflection;
            }
            
            CGRect m = self.menuView.frame;
            CGRect c = self.contentView.frame;
            if (delta > kCIBSideViewControllerMenuViewDepth) {
                m.origin.x = 0.0f;
                c.origin.x = kCIBSideViewControllerMenuViewDepth * deflection;
            }
            else if (delta < 0.0f) {
                m.origin.x = kCIBSideViewControllerMenuViewInitialOffset;
                c.origin.x = 0.0f;
            }
            else {
                // While the contentView can move up to kCIBSideViewControllerMenuViewDepth points, to achieve a parallax effect
                // the menuView has move no more than kCIBSideViewControllerMenuViewInitialOffset points
                m.origin.x = kCIBSideViewControllerMenuViewInitialOffset
                           - (delta * kCIBSideViewControllerMenuViewInitialOffset) / kCIBSideViewControllerMenuViewDepth;

                c.origin.x = delta * deflection;
            }
            
            if (self.derection == CIBSideViewControllerDirectionLeft)
                self.menuView.frame = m;
            self.contentView.frame = c;
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:

            if (self.sideViewState == CIBSideViewControllerStateOpening) {
                CGFloat contentViewLocation = self.contentView.frame.origin.x;
                if (contentViewLocation * deflection == kCIBSideViewControllerMenuViewDepth) {
                    // 拖拽已到位，直接置为菜单打开状态
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self didOpen];
                }
                else if (contentViewLocation * deflection > self.view.bounds.size.width / 4
                         && velocity.x * deflection > 0.0f) {
                    // 拖拽超过屏幕1/4，动画打开菜单
                    [self animateOpening];
                }
                else {
                    // 拖拽打开菜单在未完成时被放弃，动画关闭菜单
                    [self didOpen];
                    [self willClose];
                    [self animateClosing];
                }

            } else if (self.sideViewState == CIBSideViewControllerStateClosing) {
                CGFloat contentViewLocation = self.contentView.frame.origin.x;
                if (contentViewLocation == 0.0f) {
                    // 拖拽已到位，直接置为菜单关闭状态
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self didClose];
                }
                else if (deflection > 0
                         && contentViewLocation < (3 * self.view.bounds.size.width) / 4
                         && velocity.x < 0.0f) {
                    // 拖拽超过屏幕1/4，动画关闭菜单
                    [self animateClosing];
                }
                else if (deflection < 0
                         && kCIBSideViewControllerMenuViewDepth + contentViewLocation > self.view.bounds.size.width / 4
                         && velocity.x > 0.0f) {
                    // 拖拽超过屏幕1/4，动画关闭菜单
                    [self animateClosing];
                }
                else {
                    // 拖拽关闭菜单在未完成时被放弃
                    [self didClose];

                    // 从前位置动画重新打开菜单（不带willOpen通知）
                    CGRect l = self.menuView.frame;
                    [self willOpen];
                    self.menuView.frame = l;
                    
                    [self animateOpening];
                }
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Animations
#pragma mark 菜单打开动画
- (void)animateOpening {
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateOpening);
    NSParameterAssert(self.menuView);
    NSParameterAssert(self.contentView);
    
    // 计算menu和content的最终位置
    CGRect menuViewFinalFrame = self.view.bounds;
    CGRect contentViewFinalFrame = self.view.bounds;
    contentViewFinalFrame.origin.x = kCIBSideViewControllerMenuViewDepth;
    
    if (self.derection != CIBSideViewControllerDirectionLeft) {  // 非左即右
        menuViewFinalFrame.origin.x = self.view.bounds.size.width - kCIBSideViewControllerMenuViewDepth;
        contentViewFinalFrame.origin.x *= -1;
    }
    
    [UIView animateWithDuration:kCIBSideViewControllerAnimationDuration
                          delay:0
         usingSpringWithDamping:kCIBSideViewControllerOpeningAnimationSpringDamping
          initialSpringVelocity:kCIBSideViewControllerOpeningAnimationSpringInitialVelocity
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.contentView.frame = contentViewFinalFrame;
                         self.menuView.frame = menuViewFinalFrame;
                         
                         [self setNeedsStatusBarAppearanceUpdate];
                     }
                     completion:^(BOOL finished) {
                         [self didOpen];
                     }];
}
#pragma mark 菜单关闭动画
- (void)animateClosing {
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateClosing);
    NSParameterAssert(self.menuView);
    NSParameterAssert(self.contentView);
    
    // 计算menu和content的最终位置
    CGRect menuViewFinalFrame = self.menuView.frame;
    CGRect contentViewFinalFrame = self.view.bounds;
    
    if (self.derection == CIBSideViewControllerDirectionLeft) {
        menuViewFinalFrame.origin.x = kCIBSideViewControllerMenuViewInitialOffset;
    }
    else {
        menuViewFinalFrame.origin.x = self.view.bounds.size.width - kCIBSideViewControllerMenuViewDepth;
    }
    
    [UIView animateWithDuration:kCIBSideViewControllerAnimationDuration
                          delay:0
         usingSpringWithDamping:kCIBSideViewControllerClosingAnimationSpringDamping
          initialSpringVelocity:kCIBSideViewControllerClosingAnimationSpringInitialVelocity
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.contentView.frame = contentViewFinalFrame;
                         self.menuView.frame = menuViewFinalFrame;
                         
                         [self setNeedsStatusBarAppearanceUpdate];
                     }
                     completion:^(BOOL finished) {
                         [self didClose];
                     }];
}

#pragma mark - Opening the sideView

- (void)open {
//    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateClosed);
    if (self.sideViewState != CIBSideViewControllerStateClosed) {
        return;
    }

    [self willOpen];
    
    [self animateOpening];
}

- (void)willOpen {
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateClosed);
    NSParameterAssert(self.menuView);
    NSParameterAssert(self.contentView);
    NSParameterAssert(self.menuViewController);
    NSParameterAssert(self.contentViewController);
    
    // 更新sideView状态
    self.sideViewState = CIBSideViewControllerStateOpening;
    
    // 设置menu位置
    CGRect m = self.view.bounds;
    if (self.derection == CIBSideViewControllerDirectionLeft) {
        m.origin.x = kCIBSideViewControllerMenuViewInitialOffset;
    }
    else {
        m.origin.x = self.view.bounds.size.width - kCIBSideViewControllerMenuViewDepth;
    }
    self.menuView.frame = m;
    
    // 将menu view controller添加到container中
    [self addChildViewController:self.menuViewController];
    self.menuViewController.view.frame = self.menuView.bounds;
    [self.menuView addSubview:self.menuViewController.view];

    // 将menu view添加到view hierarchy
    [self.view insertSubview:self.menuView belowSubview:self.contentView];
    
    // 通知子controller sideViewControllerWillOpen状态
    if ([self.menuViewController respondsToSelector:@selector(sideViewControllerWillOpen:)]) {
        [self.menuViewController sideViewControllerWillOpen:self];
    }
    if ([self.contentViewController respondsToSelector:@selector(sideViewControllerWillOpen:)]) {
        [self.contentViewController sideViewControllerWillOpen:self];
    }
}

- (void)didOpen {
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateOpening);
    NSParameterAssert(self.menuViewController);
    NSParameterAssert(self.contentViewController);
    
    // Complete adding the menu controller to the container
    [self.menuViewController didMoveToParentViewController:self];
    
    [self addClosingGestureRecognizers];
    
    // 更新sideView状态
    self.sideViewState = CIBSideViewControllerStateOpen;
    
    // 通知子controller sideViewControllerDidOpen状态
    if ([self.menuViewController respondsToSelector:@selector(sideViewControllerDidOpen:)]) {
        [self.menuViewController sideViewControllerDidOpen:self];
    }
    if ([self.contentViewController respondsToSelector:@selector(sideViewControllerDidOpen:)]) {
        [self.contentViewController sideViewControllerDidOpen:self];
    }
}

#pragma mark - Closing the sideView

- (void)close {
//    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateOpen);
    if (self.sideViewState != CIBSideViewControllerStateOpen) {
        return;
    }

    [self willClose];

    [self animateClosing];
}

- (void)willClose {
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateOpen);
    NSParameterAssert(self.menuViewController);
    NSParameterAssert(self.contentViewController);
    
    // 即将把menu controller从container中移除
    [self.menuViewController willMoveToParentViewController:nil];
    
    // 更新sideView状态
    self.sideViewState = CIBSideViewControllerStateClosing;
    
    // 通知子controller sideViewControllerWillClose状态
    if ([self.menuViewController respondsToSelector:@selector(sideViewControllerWillClose:)]) {
        [self.menuViewController sideViewControllerWillClose:self];
    }
    if ([self.contentViewController respondsToSelector:@selector(sideViewControllerWillClose:)]) {
        [self.contentViewController sideViewControllerWillClose:self];
    }
}

- (void)didClose {
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateClosing);
    NSParameterAssert(self.menuView);
    NSParameterAssert(self.contentView);
    NSParameterAssert(self.menuViewController);
    NSParameterAssert(self.contentViewController);
    
    // Complete removing the menu view controller from the container
    [self.menuViewController.view removeFromSuperview];
    [self.menuViewController removeFromParentViewController];
    
    // 将menu view从view hierarchy重移除
    [self.menuView removeFromSuperview];
    
    [self removeClosingGestureRecognizers];
    
    // 更新sideView状态
    self.sideViewState = CIBSideViewControllerStateClosed;
    
    // 通知子controller sideViewControllerDidClose状态
    if ([self.menuViewController respondsToSelector:@selector(sideViewControllerDidClose:)]) {
        [self.menuViewController sideViewControllerDidClose:self];
    }
    if ([self.contentViewController respondsToSelector:@selector(sideViewControllerDidClose:)]) {
        [self.contentViewController sideViewControllerDidClose:self];
    }
}

#pragma mark - Reloading/Replacing the content view controller

- (void)reloadContentViewControllerUsingBlock:(void (^)(void))reloadBlock {
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateOpen);
    NSParameterAssert(self.contentViewController);
    
    [self willClose];
    
    CGRect f = self.contentView.frame;
    if (self.derection == CIBSideViewControllerDirectionLeft) {
        f.origin.x = self.view.bounds.size.width;
    }
    else {
        f.origin.x = 0 - self.view.bounds.size.width;
    }
    
    [UIView animateWithDuration: kCIBSideViewControllerAnimationDuration / 2
                     animations:^{
                         self.contentView.frame = f;
                     }
                     completion:^(BOOL finished) {
                         // 执行reload block
                         if (reloadBlock) {
                             reloadBlock();
                         }
                         // 关闭菜单
                         [self animateClosing];
                     }];
}

- (void)replaceContentViewControllerWithViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)viewController {
    
    NSParameterAssert(viewController);
    NSParameterAssert(self.contentView);
    NSParameterAssert(self.contentViewController);
    
    // 以下为菜单栏未打开时的替换，带动画效果
    if (self.sideViewState == CIBSideViewControllerStateClosed) {
        
        // 截屏
        UIGraphicsBeginImageContext(self.contentView.bounds.size);
        [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 使用截屏覆盖后台变化
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        imageView.image = image;
        imageView.alpha = 0.9f;
        [[[UIApplication sharedApplication] keyWindow] addSubview:imageView];
        
        // 更换controller
        [self.contentViewController willMoveToParentViewController:nil];
        // 将当前content view controller从container中移除
        if ([self.contentViewController respondsToSelector:@selector(setSideView:)]) {
            self.contentViewController.sideView = nil;
        }
        [self.contentViewController.view removeFromSuperview];
        [self.contentViewController removeFromParentViewController];
        
        // 设置新的content view controller
        self.contentViewController = viewController;
        if ([self.contentViewController respondsToSelector:@selector(setSideView:)]) {
            self.contentViewController.sideView = self;
        }
        
        // 将新的content view controller添加到container中
        [self addContentViewController];
        
        // 动画去除截屏
        CGRect f0 = self.contentView.frame;
        f0.origin = self.contentView.center;
        f0.size = CGSizeMake(0, 0);
        [UIView animateWithDuration: kCIBSideViewControllerAnimationDuration / 2
                         animations:^{
                             imageView.frame = f0;
                             imageView.alpha = 0.f;
                         }
                         completion:^(BOOL finished) {
                             [imageView removeFromSuperview];
                         }];

        return;
    }
    
    // 以下为菜单栏打开时的替换，带动画效果
    NSParameterAssert(self.sideViewState == CIBSideViewControllerStateOpen);
    
    [self willClose];
    
    CGRect f = self.contentView.frame;
    if (self.derection == CIBSideViewControllerDirectionLeft) {
        f.origin.x = self.view.bounds.size.width;
    }
    else {
        f.origin.x = 0 - self.view.bounds.size.width;
    }
    
    [self.contentViewController willMoveToParentViewController:nil];
    [UIView animateWithDuration: kCIBSideViewControllerAnimationDuration / 2
                     animations:^{
                         self.contentView.frame = f;
                     }
                     completion:^(BOOL finished) {
                         // 将当前content view controller从container中移除
                         if ([self.contentViewController respondsToSelector:@selector(setSideView:)]) {
                             self.contentViewController.sideView = nil;
                         }
                         [self.contentViewController.view removeFromSuperview];
                         [self.contentViewController removeFromParentViewController];
                         
                         // 设置新的content view controller
                         self.contentViewController = viewController;
                         if ([self.contentViewController respondsToSelector:@selector(setSideView:)]) {
                             self.contentViewController.sideView = self;
                         }
                         
                         // 将新的content view controller添加到container中
                         [self addContentViewController];
                         
                         // 关闭菜单
                         [self animateClosing];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
