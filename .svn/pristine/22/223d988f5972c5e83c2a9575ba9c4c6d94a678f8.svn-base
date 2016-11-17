

#import <Foundation/Foundation.h>

#pragma mark --
#pragma mark -- 可以使用此Key来获取应用的状态，状态值参见系统的 * UIApplicationState *
static NSString *const AppStateKey = @"AppStateKey";  // 应用状态key

#pragma mark --
#pragma mark -- 创建本地通知时的Action值
typedef NS_ENUM(NSUInteger, LocalPushActionType) {
    LocalPushDefaultAction = 0,     //默认Action，无任何操作。actionValue = @“”
    LocalPushOpenPageAction = 1,    //打开注册过的某个界面，对应的Value为界面别名。actionValue = @“DemoPage”
    LocalPushOpenUrlAction = 3      //打开某个URL，对应的Value为你希望打开的URL。actionValue = @“http://mpush.cn”
};


#pragma mark --
#pragma mark -- PushManager 通知代理

@protocol PushManagerDelegate <NSObject>

/**
*  收到消息后的代理回调方法
*
*  @param title     消息title内容
*  @param content   消息content内容
*  @param extention 参数字典,此字典包含用户自定义参数和应用状态参数。 获取应用状态参数可通过 AppStateKey 来获取，状态类型参见 * UIApplicationState *
*
*  @return BOOL 当返回YES时，仅处理至当前事件处，后续事件将不再执行，当返回NO时，按照事件链继续执行，直至返回YES或者所有事件执行完。
*/
- (BOOL)onMessage:(NSString *)title
          content:(NSString *)content
        extention:(NSDictionary *)extention;


@end


#pragma mark --
#pragma mark -- PushManager DeviceToken代理

@protocol DeviceTokenDelegate <NSObject>

/**
*  获取DeviceToken，此DeviceToken为苹果原生DeviceToken 的32位hex字符串。
*  如果需要原生格式的DeviceToken，可使用系统 didRegisterForRemoteNotificationsWithDeviceToken 方法获取
*
*  @return deviceToken
*/
- (void)didReciveDeviceToken:(NSString *)deviceToken;
@end


#pragma mark --
#pragma mark -- PushManager 主体类接口

@interface PushManager : NSObject

/**
 *  开启推送服务并设置相关参数
 *
 *  @param pushDelegate  推送消息代理
 *  @param tokenDelegate DeviceToken代理
 *  @param displaysMap   自定义展示界面，可为空nil
 */
+ (void)startPushServicePushDelegate:(id <PushManagerDelegate>)pushDelegate
                       tokenDelegate:(id <DeviceTokenDelegate>)tokenDelegate;

/**
 *  定义打开应用内某个页面
 *
 *  @param displayViews 需要展示的界面
 *  @param viewAlias    针对每个界面指定的别名
 *  @param methods      传递参数到界面的方法
 *  @param displayModes 界面打开的方式，目前有两种方式可指定。PUSH  和  PRESENT，指定时以字符串的方式指定，默认是PRESENT方式。
 */
+ (void)setDisplayViews:(NSArray *)displayViews
              viewAlias:(NSArray *)viewAlias
                methods:(NSArray *)methods
           displayModes:(NSArray *)displayModes;

/**
*  设置推送代理方法，可多次调用
*
*  @warning  此方法必须在startPushService:.....方法之后调用！！！
*  @param delegate 推送消息代理
*  @param append   追加代理，append：YES 为追加  append：NO 为不追加，将代理放置第一位
*/
+ (void)setPushDelegate:(id <PushManagerDelegate>)delegate append:(BOOL)append;

//  以下方法为可选

/**
*  设置是否允许SDK当应用在前台运行收到Push时弹出Alert框（默认关闭）
*  @warning  透传消息始终不会弹出Alert框，如需要弹出，请在消息回调方法中自定义！
*  @param value 是否开启弹出框
*/
+ (void)setAutoShowAlert:(BOOL)value;

/**
*  是否开启调试日志，默认为不开启
*
*  @param enabled YES  打开  NO 关闭
*/
+ (void)setDebugMode:(BOOL)enabled;


#pragma MARK --
#pragma MARK --  本地通知

/**
*  本地推送，最多支持64个
*
*  @param title      通知标题
*  @param content    通知内容
*  @param actionType   动作类型  (定义接收到本地通知时，可执行的动作类型，可参见 LocalPushActionType 枚举)
*  @param actionValue   动作参数 (定义接收到本地通知时，可执行的动作参数，根据 LocalPushActionType 设置)
*  @param extention  自定义参数集合
*  @param fireDate   通知发生时间
*
*  @return SDK分配给本通知的唯一标识 key
*/
+ (NSString *)sendLocalPushMsg:(NSString *)title
                       content:(NSString *)content
                    actionType:(LocalPushActionType)actionType
                   actionValue:(NSString *)actionValue
                    extentions:(NSDictionary *)extention
                      fireDate:(NSDate *)fireDate;

/**
*  取消指定标识的单个本地通知
*
*  @param key 通知标识，为创建时所分配。
*/
+ (void)cancelLocalPushForKey:(NSString *)key;

/**
*  取消所有的本地通知
*/
+ (void)cancelAllLocalPush;


/**
*  检查版本更新,可在应用启动时调用此接口，也可以在某个按钮事件中调用.
*
*  @warning 当不适用第三方渠道时，可直接使用此接口
*  @param isNewest 是否已经是最新版本回调，开发者可以根据此返回值做界面提示等
*/
+ (void)checkNewUpdate:(void(^)(BOOL isNewest))isNewest;

/**
*  按渠道检查版本更新,可在应用启动时调用此接口，也可以在某个按钮事件中调用,需要传入渠道标识。
*
*  @param isNewest 是否已经是最新版本回调，开发者可以根据此返回值做界面提示等
*/

+ (void)checkNewUpdateWithChannel:(NSString *)channelName success:(void(^)(BOOL isNewest))isNewest;

/**
*  为设备设置别名或移除别名,设置的前提条件是设备的DeviceToken已经获取成功。
*
*  @param alias 别名名称，当为nil或者@""时，为移除别名，否则为设置别名。重复调用会自动更新至最后一次调用时的别名。
*/
+ (void)setAlias:(NSString *)alias;

/**
*  为设备设置tag，可以为多个。
*
*  @param tags tag名称。
*/
+ (void)setTags:(NSArray *)tags;

/**
*  删除设置过的tag，可以为多个。
*
*  @param tags tag名称。
*/
+ (void)deleteTags:(NSArray *)tags;

/**
*  获取验证码接口（调用此接口前，请确保手机号正常可用。）
*
*  @param mobile       手机号
*  @param timeInterval 验证码有效时间，单位分钟，默认为3分钟
*  @param finishBlock  接口请求成功后的回调 成功是返回code，失败或者其他错误返回errorMsg
*/
+ (void)authSms:(NSString *)mobile timeInterval:(NSTimeInterval)timeInterval finished:(void (^)(NSString *code, NSString *errorMsg))finishBlock;

/**
*
*   如果使用独立托管的mpush server，需要获取设备唯一标识的话，可使用此接口。
*
* */
+ (NSString *)getPushId;

@end
