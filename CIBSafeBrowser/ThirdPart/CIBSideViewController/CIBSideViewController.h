//
//  CIBSideViewController.h
//
//  实现侧边菜单效果
//
//  Created by cib on 14/12/31.
//  Copyright (c) 2014年 cib. All rights reserved.
//
//  代码借鉴了Vito Modena的单侧侧边栏示例，特此感谢
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CIBSideViewControllerDirection)
{
    CIBSideViewControllerDirectionLeft = 0,  // 菜单在左侧
    CIBSideViewControllerDirectionRight      // 菜单在右侧
};

@protocol CIBSideViewControllerChild;
@protocol CIBSideViewControllerPresenting;

/**
 CIBSideViewController适用于iOS7.0+，用于实现一个侧边栏菜单效果（支持左侧或右侧，默认菜单在左侧），实质上是一个container controller，其内部接受两个子controller：菜单controller和内容controller。菜单controller在CIBSideViewController处于open（状态）时可见，用于更新或替换内容controller位置的内容；内容controller位置显示当前展现给用户的细节，在CIBSideViewController处于close（状态）时全部可见。
 
 ## 打开/关闭侧边菜单
 CIBSideViewController默认使用一个UIPanGestureRecognizer来打开/关闭侧边菜单，该方式可以通过调用setPanGestureControllEnable:方法予以禁用；同时，CIBSideViewController使用一个UITapGestureRecognizer来关闭侧边菜单，只需要在侧边菜单打开状态下点击内容controller区域内的任何地方即可。此外，还可以通过调用open/close方法来在你需要的时候打开/关闭侧边菜单。通过采用“CIBSideViewControllerChild”协议并实现property “sideView”，可以操作相应的CIBSideViewController实例。
 
 ## 获取侧边菜单变化
 当侧边菜单状态发生变化时，CIBSideViewController将发送以下通知，开发者可以针对做相应处理（通过采用”CIBSideViewControllerPresenting“协议）:
 - sideViewControllerWillOpen: 菜单即将打开
 - sideViewControllerDidOpen: 菜单已打开
 - sideViewControllerWillClose: 菜单即将关闭
 - sideViewControllerDidClose: 菜单已关闭
 
 ## 使用方法
 1. 将CIBSideViewController添加到xcode工程中；
 2. 根据需要，在你的菜单或内容controllers中采用“CIBSideViewControllerChild” 协议并实现property “sideView”；
 3. 根据需要，在你的菜单或内容controllers中采用“CIBSideViewControllerPresenting” 协议；
 4. 用相应的菜单controller和内容controller对CIBSideViewController实例进行初始化，并设置菜单方向
    YourMenuViewController *menu = [[YourMenuViewController alloc] init];
    YourContentViewController *content = [[YourContentViewController alloc] init];
    CIBSideViewController *sideView = [[CIBSideViewController alloc] initWithMenuViewController:menu
                                                                     contentViewController:content];
    [sideView setDerection:CIBSideViewControllerDirectionRight];  // 默认setDerection:CIBSideViewControllerDirectionLeft
 
 */
@interface CIBSideViewController : UIViewController

/**
 菜单controller
 在CIBSideViewController处于open（状态）时可见，在CIBSideViewController实例初始化时设置。
 @see initWithMenuViewController:contentViewController:
 */
@property(nonatomic, strong, readonly) UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *menuViewController;

/**
 内容controller
 当前展现给用户的内容，在CIBSideViewController处于close（状态）时全部可见；可通过调用“replacecontentViewControllerWithViewController:”方法对其进行替换。
 @see replaceContentViewControllerWithViewController:
 */
@property(nonatomic, strong, readonly) UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *contentViewController;

/**
 侧边菜单的位置，默认CIBSideViewControllerDirectionLeft：
 - CIBSideViewControllerDirectionLeft：菜单在左侧弹出；
 - CIBSideViewControllerDirectionRight：菜单在右侧弹出。
 */
@property(nonatomic, assign) CIBSideViewControllerDirection derection;

/**
 @name Initialization
 */
/**
 通过给定的子controllers初始化并返回一个CIBSideViewController对象（默认菜单宽度260）

 @param menuViewController 菜单controller，不能是nil。
 @param contentViewController 内容controller，不能是nil。

 @return 相应的CIBSideViewController实例，创建实例失败时返回nil
 */
- (id)initWithMenuViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)menuViewController
           contentViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)contentViewController;

/**
 @name Initialization
 */
/**
 通过给定的子controllers初始化并返回一个CIBSideViewController对象（指定菜单宽度）
 
 @param menuViewController 菜单controller，不能是nil。
 @param contentViewController 内容controller，不能是nil。
 @param depth 菜单深度（宽度）。
 
 @return 相应的CIBSideViewController实例，创建实例失败时返回nil
 */
- (id)initWithMenuViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)menuViewController
           contentViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)contentViewController
                   menuViewDepth:(CGFloat)depth;

/**
 启用/禁用通过拖拽手势来打开/关闭侧边菜单（侧边触发深度默认60）
 @param enable 是否允许
 */
- (void)setPanGestureControllEnable:(BOOL)enable;

/**
 启用/禁用通过拖拽手势来打开/关闭侧边菜单
 @param enable 是否允许
 @param enable 侧边触发深度（从距侧边Depth距离内开始拖拽有效）
 */
- (void)setPanGestureControllEnable:(BOOL)enable triggerDepth:(CGFloat)depth;

/**
 打开侧边菜单
 一般情况下，通过tap内容controller中的菜单按钮触发调用。
 */
- (void)open;

/**
 关闭侧边菜单
 在需要的时候关闭侧边菜单可调用改方法，与tap内容controller区域内的任何一处关闭侧边菜单的效果一致。
 */
- (void)close;

/**
 关闭侧边菜单并重新加载内容controller区域的内容
 在需要重新加载内容时调用，并在关闭侧边菜单时执行“reloadBlock”回调。
 @param reloadBlock 用于重新加载时的回调
 */
- (void)reloadContentViewControllerUsingBlock:(void (^)(void))reloadBlock;

/**
 关闭侧边菜单并替换内容controller区域的内容

 @param viewController 将要替换原有内容controller的新controller
 */
- (void)replaceContentViewControllerWithViewController:(UIViewController<CIBSideViewControllerChild, CIBSideViewControllerPresenting> *)viewController;

@end


/**
 CIBSideViewControllerChild协议用于让CIBSideViewController中的子controller（菜单controller和内容controller）访问CIBSideViewController实例（通过“sideView”）。
 只要子controller采用CIBSideViewControllerChild协议，sideView将在子controller添加到CIBSideViewController实例中时被自动初始化。
 */
@protocol CIBSideViewControllerChild <NSObject>

/**
 sideView，相应CIBSideViewController实例的引用
 */
@property(nonatomic, weak) CIBSideViewController *sideView;

@end


/**
 CIBSideViewControllerPresenting协议用于实现侧边菜单打开/关闭状态切换时，子controller的相应处理。例如可以在侧边菜单打开/关闭时，设置内容controller的interaction属性，避免误操作干扰。
 */
@protocol CIBSideViewControllerPresenting <NSObject>

@optional

/**
 通知子controller侧边菜单即将打开
 @param sideViewController 相应的CIBSideViewController实例
 */
- (void)sideViewControllerWillOpen:(CIBSideViewController *)sideViewController;

/**
 通知子controller侧边菜单打开完毕
 @param sideViewController 相应的CIBSideViewController实例
 */
- (void)sideViewControllerDidOpen:(CIBSideViewController *)sideViewController;

/**
 通知子controller侧边菜单即将关闭
 @param sideViewController 相应的CIBSideViewController实例
 */
- (void)sideViewControllerWillClose:(CIBSideViewController *)sideViewController;

/**
 通知子controller侧边菜单关闭完毕
 @param sideViewController 相应的CIBSideViewController实例
 */
- (void)sideViewControllerDidClose:(CIBSideViewController *)sideViewController;

@end