//
//  SearchViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 15/3/10.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "SearchViewController.h"

#import "SearchResultCell.h"
#import "AppProduct.h"
#import "CustomWebViewController.h"
#import "AppDelegate.h"

#import "MyUtils.h"
#import "CoreDataManager.h"
#import "Config.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "ImageAlertView.h"

#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "PopupView.h"
#import "ISRDataHelper.h"
#import "IATConfigViewController.h"
#import "IATConfig.h"

#import <CIBBaseSDK/CIBRequestOperationManager.h>
#import <CIBBaseSDK/URLAddressManager.h>
#import <CIBBaseSDK/AppInfoManager.h>

#import "UserInfoViewController.h"

#define IS_iPad  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define err_message @"搜索内容中不能包含特殊字符（只能是数字、字母、汉子）"
@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSUserDefaults *user;         //存储数据
    BOOL isSearchHistory;         //tableview加载的是搜索历史记录列表
    BOOL isPeopleList;            //tableView加载的是搜索联系人结果列表
    UIView *lBottomLine;          //练习人按钮底部分割线
    UIView *rBottomLine;          //应用按钮底部分割线
    UIButton *peopleBtn;          //联系人按钮
    UIButton *applicationBtn;     //应用按钮
    BOOL  cellIsSelected;         //cell被点击
    BOOL useVoiceRecognize;       //是否使用语言听写
    
    
}
@property (nonatomic ,strong) NSMutableArray *searchHisArr; //搜索历史列表
@property (nonatomic ,strong) NSMutableArray *list;  // 搜索结果列表
@property (nonatomic ,strong) NSMutableArray *peopleList;  //联系人列表
@property (nonatomic ,strong) NSMutableArray *applicationList; //应用列表

@property (strong, nonatomic) UIView *searchBgView;

@property(nonatomic,strong) UserInfoViewController* userInfoController;

- (IBAction)cancelBtnPress:(id)sender;  // 响应取消按钮

//改动
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@end

@implementation SearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    useVoiceRecognize = [[MyUtils propertyOfResource:@"Setting" forKey:@"UseVoiceRecognize"] boolValue];
    cellIsSelected = NO;
    isPeopleList = NO;
    isSearchHistory = YES;
    self.list = [[NSMutableArray alloc] init];
    self.peopleList = [[NSMutableArray alloc] init];
    self.applicationList = [[NSMutableArray alloc] init];
    [self initSearchTextField];
    self.searchHisArr = [self readDataUserDefaults];
    self.resultTableView.tableFooterView = [[UIView alloc] init];
    [self.resultTableView setSeparatorColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
    self.resultTableView.bounces = NO;
    [self.resultTableView reloadData];
    if (useVoiceRecognize) {
        _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.0 - 20, self.view.frame.size.height / 2.0 - 20, 40, 20) withParentView:self.view];
        
        //录音文件保存路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        _pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
        
        self.uploader = [[IFlyDataUploader alloc] init];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"%s",__func__);
    
    [super viewWillAppear:animated];
    
    [self initRecognizer];//初始化识别对象
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
    else
    {
        [_iflyRecognizerView cancel]; //取消识别
        [_iflyRecognizerView setDelegate:nil];
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    }
    
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.view = nil;
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        [_popUpView removeFromSuperview];
        return;
    }
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [_popUpView showText: vol];
}



/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"beginDate.");
    NSLog(@"onBeginOfSpeech");
    [_popUpView showText: @"正在录音"];
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    
    [_popUpView showText: @"停止录音"];
}


/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO ) {
        NSString *text ;
        
        if (self.isCanceled) {
            text = @"识别取消";
            
        } else if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = @"无识别结果";
            }else {
                text = @"识别成功";
            }
        }else {
            text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
            NSLog(@"%@",text);
        }
        
        [_popUpView showText: text];
        
    }else {
        [_popUpView showText:@"识别结束"];
        NSLog(@"errorCode:%d",[error errorCode]);
    }
    
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    _result =[NSString stringWithFormat:@"%@%@", _searchTextField.text,resultString];
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    _searchTextField.text = [NSString stringWithFormat:@"%@%@", _searchTextField.text,resultFromJson];
    NSString *resultStr = _searchTextField.text;
    if (_searchTextField.text.length > 0 && [[_searchTextField.text substringFromIndex:_searchTextField.text.length - 1] isEqualToString:@"。"]) {
        _searchTextField.text = [resultStr substringToIndex:resultStr.length - 1];
    }
    
    if (isLast){
        [self textFieldShouldReturn:self.searchTextField];
        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
    NSLog(@"endDate.");
    NSLog(@"_result=%@",_result);
    NSLog(@"resultFromJson=%@",resultFromJson);
    NSLog(@"isLast=%d,_textView.text=%@",isLast,_searchTextField.text);
}



/**
 有界面，听写结果回调
 resultArray：听写结果
 isLast：表示最后一次
 ****/
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    _searchTextField.text = [NSString stringWithFormat:@"%@%@",_searchTextField.text,result];
}



/**
 听写取消回调
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}

-(void) showPopup
{
    [_popUpView showText: @"正在上传..."];
}

#pragma mark - IFlyDataUploaderDelegate

/**
 上传联系人和词表的结果回调
 error ，错误码
 ****/
- (void) onUploadFinished:(IFlySpeechError *)error
{
    NSLog(@"%d",[error errorCode]);
    
    if ([error errorCode] == 0) {
        [_popUpView showText: @"上传成功"];
    }
    else {
        [_popUpView showText: [NSString stringWithFormat:@"上传失败，错误码:%d",error.errorCode]];
        
    }
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    }else  {//有界面
        
        //单例模式，UI的实例
        if (_iflyRecognizerView == nil) {
            //UI显示剧中
            _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
            
            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            
        }
        _iflyRecognizerView.delegate = self;
        
        if (_iflyRecognizerView != nil) {
            IATConfig *instance = [IATConfig sharedInstance];
            //设置最长录音时间
            [_iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            if ([instance.language isEqualToString:[IATConfig chinese]]) {
                //设置语言
                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[IATConfig english]]) {
                //设置语言
                [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
            
        }
    }
}

// 初始化，为textfield增加右侧搜索标识
- (void)initSearchTextField {
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 8, 38, 30)];
    rightView.backgroundColor = [UIColor clearColor];
    UIImageView *image;
    if (useVoiceRecognize) {
        image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice.jpg"]];
        CGRect frame =  CGRectMake(rightView.frame.origin.x + 10, rightView.center.y - 18, 15, 21);
        image.frame = frame;

    }else{
        image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_search blue"]];
        CGRect frame =  CGRectMake(rightView.frame.origin.x + 6, rightView.center.y - 18, 20, 21);
        image.frame = frame;
    }

    [rightView addSubview:image];

    self.searchTextField.rightView = rightView;
//    self.searchTextField.layer.cornerRadius = 16;
    self.searchTextField.clipsToBounds = 16;
    UIView *leftView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    leftView.backgroundColor=[UIColor clearColor];
    self.searchTextField.leftView = leftView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.searchTextField addTarget:self action:@selector(searchTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    // 为右侧的放大镜图标也添加点击事件
    self.searchTextField.rightView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchIconTapped)];
    [self.searchTextField.rightView addGestureRecognizer:tapGesture];
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 是否支持转屏
- (BOOL)shouldAutorotate {
    if (IS_iPad) {
        return YES;
    }else
    {
        return NO;
    }
}
// 屏幕将要旋转时执行的方法
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0){
    [self.resultTableView reloadData];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userinfoSegue"]) {
        self.userInfoController = [segue destinationViewController];
        self.userInfoController.notesId=sender;
    }
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //判断是否包含特殊字符
    if(![textField.text isEqualToString:@""] && [self isValidateSucc:textField.text]){
        [self.list removeAllObjects];
        [self.peopleList removeAllObjects];
        [self.applicationList removeAllObjects];
        [self searchAppAndUser:textField];
        [self.searchTextField resignFirstResponder];
    }else{
        [MyUtils showAlertWithTitle:err_message message:nil];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    isSearchHistory = YES;
    isPeopleList = NO;
    self.searchHisArr = [self readDataUserDefaults];
    [self.resultTableView reloadData];

    

}
- (void)searchIconTapped {
    if (useVoiceRecognize) {
        NSLog(@"%s[IN]",__func__);
        
        if ([IATConfig sharedInstance].haveView == NO) {//无界面
            
            [_searchTextField setText:@""];
            [_searchTextField resignFirstResponder];
            self.isCanceled = NO;
            
            if(_iFlySpeechRecognizer == nil)
            {
                [self initRecognizer];
            }
            
            [_iFlySpeechRecognizer cancel];
            
            //设置音频来源为麦克风
            [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            
            //设置听写结果格式为json
            [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
            
            //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
            [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
            
            [_iFlySpeechRecognizer setDelegate:self];
            
            BOOL ret = [_iFlySpeechRecognizer startListening];
            
            if (ret) {
            }else{
                [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
            }
        }else {
            
            if(_iflyRecognizerView == nil)
            {
                [self initRecognizer ];
            }
            
            [_searchTextField setText:@""];
            [_searchTextField resignFirstResponder];
            
            //设置音频来源为麦克风
            [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            
            //设置听写结果格式为json
            [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
            
            //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
            [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
            
            [_iflyRecognizerView start];
        }

    }else{
        [self textFieldShouldReturn:self.searchTextField];
    }
    
}

// 搜索结果并加载
- (void)searchTextDidChange:(UITextField *)textField {

}

// 响应取消按钮
- (IBAction)cancelBtnPress:(id)sender {
    float height =   [UIScreen mainScreen].bounds.size.height;
    float width = [UIScreen mainScreen].bounds.size.width;
    if (IS_iPad && (height < width)) {
       [[NSNotificationCenter defaultCenter] postNotificationName:@"pressCancelBtn" object:nil];
    }
    [self.view.superview setHidden:YES];
    [self resetSearch];
}

// 重置搜索区域（清空）
- (void)resetSearch {
    [self.searchTextField setText:@""];
    [self.searchTextField resignFirstResponder];
    [self.list removeAllObjects];
    [self.peopleList removeAllObjects];
    [self.applicationList removeAllObjects];
    [self.resultTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isSearchHistory) {
        return self.searchHisArr.count;
    }else if (isPeopleList){
        return self.peopleList.count;}
    else{
        return self.applicationList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 加载数据
    if (isSearchHistory) //如果加载的是搜索历史记录列表
    {
        static NSString *cellIdentifier = @"cellIdentifier";
        UITableViewCell *cell = [self.resultTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }else{
            
            // 删除cell中的子对象,刷新覆盖问题
            while ([cell.contentView.subviews lastObject] != nil) {
                [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
        }
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.text = [self.searchHisArr objectAtIndex:indexPath.row];
        cell.textLabel.textColor = UIColorFromRGB(0x3c3c3c);
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        CGRect rect = [UIScreen mainScreen].bounds;
        CGSize size = rect.size;
        CGFloat width = size.width;
        UIButton *deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(width - 33, cell.contentView.center.y - 9.5, 25, 25)];
        [deleteBtn setImage:[UIImage imageNamed:@"deletesearchHis"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteSearchHis:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:deleteBtn];
        
        return cell;
        
    }else if(isPeopleList) //如果加载的是联系人列表
    {
        static NSString *CellIdentifier = @"SearchPrototypeCell1";
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell =  [self.resultTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UIImageView *iconImageView;
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }else{
            // 删除cell中的子对象,刷新覆盖问题
            while ([cell.contentView.subviews lastObject] != nil) {
                 [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
        }
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, cell.center.y - 16, 50, 50)];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, iconImageView.frame.origin.y + 8, 60, 15)];
        nameLabel.textColor = UIColorFromRGB(0x3c3c3c);
        [nameLabel setFont:[UIFont systemFontOfSize:15]];
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + 72, nameLabel.frame.origin.y, 180, 15)];
        numLabel.textColor = UIColorFromRGB(0x1277d3);
        [numLabel setFont:[UIFont systemFontOfSize:15]];
        
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        float comWidth = screenWidth-nameLabel.frame.origin.x;
        UILabel *comLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + 20, comWidth, 18)];
        [comLabel setFont:[UIFont systemFontOfSize:12]];
        comLabel.textColor = UIColorFromRGB(0x606060);
    
        NSDictionary *cellInfo = self.peopleList[indexPath.row];
        NSString *name = [cellInfo objectForKey:@"appShowName"]; // 搜索结果中展示的名字（在结果为人时，为人的真实姓名）
        NSString *notesId = [cellInfo objectForKey:@"notesId"];
        NSString *imgAddress = [cellInfo objectForKey:@"imgAddress"];
        NSString *orgName = [cellInfo objectForKey:@"orgName"];
        NSString *appNo = [cellInfo objectForKey:@"appNo"];
        
        if (imgAddress && ![imgAddress isEqualToString:@""])
        {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            UIImage* image = [[manager imageCache] imageFromMemoryCacheForKey:imgAddress];
            if (image)
            {
                iconImageView.image = image;
            } else
            {
                // 如果是一条联系人信息
                if ([appNo isEqualToString:kAppNoOfSearchedUser] )
                {
                    [iconImageView sd_setImageWithURL:[NSURL URLWithString:imgAddress] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
                } else
                {
                    [iconImageView sd_setImageWithURL:[NSURL URLWithString:imgAddress]  placeholderImage:[UIImage imageNamed:@"defalutIcon"]];
                }
            }
        }else //如果加载的是应用列表
        {
            // 如果是一条联系人信息
            if ([appNo isEqualToString:kAppNoOfSearchedUser] )
            {
                [iconImageView sd_setImageWithURL:[NSURL URLWithString:imgAddress] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
            } else
            {
                [iconImageView sd_setImageWithURL:[NSURL URLWithString:imgAddress] placeholderImage:[UIImage imageNamed:@"defalutIcon"]];
            }
        }
        nameLabel.text = name;
        numLabel.text = [NSString stringWithFormat:@"NO.%@",notesId];
        comLabel.text =orgName;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:numLabel];
        [cell.contentView addSubview:comLabel];
        [cell.contentView addSubview:iconImageView];
    
    return cell;
    }else
    {
        static NSString *CellIdentifier = @"SearchPrototypeCell2";
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell = [self.resultTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }else{
            
            // 删除cell中的子对象,刷新覆盖问题
            while ([cell.contentView.subviews lastObject] != nil) {
                [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
        }
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIImageView *appIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, cell.center.y - 13.5, 27, 27)];
        UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, cell.center.y - 10, 100, 20)];
        [appNameLabel setFont:[UIFont systemFontOfSize:15]];
        appNameLabel.textColor = UIColorFromRGB(0x3c3c3c);
        
        NSDictionary *cellInfo = self.applicationList[indexPath.row];
        NSString *name = [cellInfo objectForKey:@"name"]; // 搜索结果中展示的名字（在结果为人时，为人的真实姓名）
        NSString *imgAddress = [cellInfo objectForKey:@"imgAddress"];
        NSString *appNo = [cellInfo objectForKey:@"appNo"];
        
        if (imgAddress && ![imgAddress isEqualToString:@""]) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            UIImage* image = [[manager imageCache] imageFromMemoryCacheForKey:imgAddress];
            if (image) {
                appIcon.image = image;
            }
            else {
                // 如果是一条联系人信息
                if ([appNo isEqualToString:kAppNoOfSearchedUser] ) {
                    [appIcon sd_setImageWithURL:[NSURL URLWithString:imgAddress] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
                } else {
                    [appIcon sd_setImageWithURL:[NSURL URLWithString:imgAddress] placeholderImage:[UIImage imageNamed:@"defalutIcon"]];
                }
            }
        }
        else {
            // 如果是一条联系人信息
            if ([appNo isEqualToString:kAppNoOfSearchedUser] ) {
                [appIcon sd_setImageWithURL:[NSURL URLWithString:imgAddress] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
            } else {
                [appIcon sd_setImageWithURL:[NSURL URLWithString:imgAddress] placeholderImage:[UIImage imageNamed:@"defalutIcon"]];
            }
        }
        
        appNameLabel.text = name;
        [cell.contentView addSubview:appNameLabel];
        [cell.contentView addSubview:appIcon];

        return cell;
    }
    
}

#pragma mark -- UITableViewDelegate
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
//添加搜索历史
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (isSearchHistory) {
        return 36;

    }else{
        return 55;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (isSearchHistory) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 36)];
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(view.frame.origin.x + 30, view.frame.origin.y, view.frame.size.width - 30, view.frame.size.height);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = UIColorFromRGB(0x929899);
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"搜索历史";
        [view addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, view.center.y - 7, 14, 14)];
        [imageView setImage:[UIImage imageNamed:@"Searchhistory"]];
        [view addSubview:imageView];
        return view;
    }else{
        CGRect rect = [UIScreen mainScreen].bounds;
        CGSize size = rect.size;
        CGFloat width = size.width;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 55)];
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width + 3, 40)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        if (width == 320) {
            peopleBtn = [[UIButton alloc]initWithFrame:CGRectMake(28 / (414 / 320.0), backgroundView.center.y - 15, 150 / (414 / 320.0), 30)];
            applicationBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.center.x + 28 / (414 / 320.0), backgroundView.center.y - 15, 150 / (414 / 320.0), 30)];
            lBottomLine = [[UIView alloc]initWithFrame:CGRectMake(28 / (414 / 320.0), 38, 150 / (414 / 320.0), 2)];
            rBottomLine = [[UIView alloc]initWithFrame:CGRectMake(view.center.x + 28 / (414 / 320.0), 38, lBottomLine.frame.size.width, 2)];
        }else if(width == 375){
            peopleBtn = [[UIButton alloc]initWithFrame:CGRectMake(28 / (414 / 375.0), backgroundView.center.y - 15, 150 / (414 / 375), 30 / (414 / 375))];
            applicationBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.center.x + 28 / (414 / 375.0), backgroundView.center.y - 15, 150 / (414 / 375.0), 30)];
            lBottomLine = [[UIView alloc]initWithFrame:CGRectMake(28 / (414 / 375.0), 38, 150 / (414 / 375.0), 2)];
            rBottomLine = [[UIView alloc]initWithFrame:CGRectMake(view.center.x + 28 / (414 / 375.0), 38, lBottomLine.frame.size.width, 2)];
        }else if(IS_iPad){
            
            peopleBtn = [[UIButton alloc]initWithFrame:CGRectMake(28 / (414 / width), backgroundView.center.y - 15, 150 / (414 / width), 30)];
            applicationBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.center.x + 28 / (414 / width), backgroundView.center.y - 15, 150 / (414 / width), 30)];
            lBottomLine = [[UIView alloc]initWithFrame:CGRectMake(28 / (414 / width), 38, 150 / (414 / width), 2)];
            rBottomLine = [[UIView alloc]initWithFrame:CGRectMake(view.center.x + 28 / (414 / width), 38, lBottomLine.frame.size.width, 2)];
        }
        else {
            peopleBtn = [[UIButton alloc]initWithFrame:CGRectMake(28, (backgroundView.center.y - 15), 150, 30)];
            applicationBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.center.x + 28, backgroundView.center.y - 15, 150, 30)];
            lBottomLine = [[UIView alloc]initWithFrame:CGRectMake(28, 38, 150, 2)];
            rBottomLine = [[UIView alloc]initWithFrame:CGRectMake(view.center.x + 28, 38, lBottomLine.frame.size.width, 2)];

        }
        [peopleBtn setTitle:@"联系人" forState:UIControlStateNormal];
        peopleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [peopleBtn setTitleColor:UIColorFromRGB(0x1277d4) forState:UIControlStateNormal];
        [peopleBtn addTarget:self action:@selector(clickPeopleBtn) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:peopleBtn];
        
        [applicationBtn setTitle:@"应用" forState:UIControlStateNormal];
        applicationBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [applicationBtn setTitleColor:UIColorFromRGB(0x606060) forState:UIControlStateNormal];
        [applicationBtn addTarget:self action:@selector(clickAppBtn) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:applicationBtn];
        
        lBottomLine.backgroundColor = UIColorFromRGB(0x1277d4);
        [backgroundView addSubview:lBottomLine];
        
        UIView *centerSeparatorLine = [[UIView alloc]initWithFrame:CGRectMake(backgroundView.center.x, backgroundView.center.y - 10, 1, 20)];
        centerSeparatorLine.backgroundColor = tableView.backgroundColor;
        [backgroundView addSubview:centerSeparatorLine];

        rBottomLine.backgroundColor = [UIColor blueColor];
        rBottomLine.hidden = YES;
        [backgroundView addSubview:rBottomLine];
        
        if (isPeopleList) {
            [peopleBtn setTitleColor:UIColorFromRGB(0x1277d4) forState:UIControlStateNormal];
            [applicationBtn setTitleColor:UIColorFromRGB(0x606060) forState:UIControlStateNormal];
              rBottomLine.hidden = YES;
        }else{
            [rBottomLine setBackgroundColor:UIColorFromRGB(0x1277d4)];
            [applicationBtn setTitleColor:UIColorFromRGB(0x1277d4) forState:UIControlStateNormal];
            [peopleBtn setTitleColor:UIColorFromRGB(0x606060) forState:UIControlStateNormal];
            lBottomLine.hidden = YES;
            rBottomLine.hidden = NO;
        }
        
        [view addSubview:backgroundView];
        return view;
    }
    
}
// 确定行高，消除Xcode Warning
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isPeopleList) {
        return 60;
    }else{
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchTextField.text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if (isSearchHistory)
    {
        if(![self.searchTextField.text isEqualToString:@""] && [self isValidateSucc:self.searchTextField.text]){
            cellIsSelected = YES;
            isPeopleList = YES;
            isSearchHistory = NO;
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self searchAppAndUser:self.searchTextField];
            cellIsSelected = NO;
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [MyUtils showAlertWithTitle:err_message message:nil];
        }
    }
    else if(isPeopleList)
    {
        // 选中后立即取消选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        // 检查网络
        if (![MyUtils isNetworkAvailableInView:self.view]) {
            [self cancelBtnPress:nil];
            return;
        }
        NSDictionary *cellInfo = self.peopleList[indexPath.row];
        [self performSegueWithIdentifier:@"userinfoSegue" sender:[cellInfo objectForKey:@"notesId" ]];
    }
    // 点击的是webApp
    else{
        // 选中后立即取消选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        // 检查网络
        if (![MyUtils isNetworkAvailableInView:self.view]) {
            [self cancelBtnPress:nil];
            return;
        }
        NSDictionary *cellInfo = self.applicationList[indexPath.row];
        NSString *appNo = [cellInfo objectForKey:@"appNo"];
        
        // 选择的是一个联系人，需要遍历tab页，若没有相同的联系人打开，则新建tab
        if ([appNo isEqualToString:kAppNoOfSearchedUser]) {
             // 理论上是不会进入这里的，因为点击的是webApp
            NSLog(@"Something is wrong!");
        }
        // 选择的是WebApp
        else {
            [self cancelBtnPress:nil];
            
            CoreDataManager *cdManager = [[CoreDataManager alloc] init];
            AppProduct *app = [cdManager getAppProductByAppNo:[NSNumber numberWithInt:[appNo intValue]]];
            
            NSString *appIndexUrl = app.appIndexUrl;
            [MyUtils openUrl:appIndexUrl ofApp:app];
        }
    }
    return;
}
//读取USerDefaults中的数据
- (NSMutableArray *)readDataUserDefaults{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *searchArr = [userDefaults arrayForKey:@"searchHis"];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:searchArr];
    
    return arr;
}
//判断 输入是否合法 （不能包含特殊字符）
-(BOOL) isValidateSucc:(NSString*) str{
    NSString * regex = @"^[A-Za-z0-9\u4E00-\u9FA5_-]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
- (void)searchAppAndUser:(UITextField *)textField {
    [self.peopleList removeAllObjects];
    [self.applicationList removeAllObjects];
    NSString *key = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (cellIsSelected) {
        
    }else{
        //保存当前的搜索key
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        if ([userDefaultes arrayForKey:@"searchHis"] == nil)//说明是第一次搜索
        {
            if (key.length > 0) {
                NSArray *seachArr = [NSArray arrayWithObject:key];
                [userDefaultes setObject:seachArr forKey:@"searchHis"];
                [userDefaultes synchronize];
            }
            
        }else{
            if (key.length > 0) {
                NSArray *searchArr = [userDefaultes arrayForKey:@"searchHis"];
                NSMutableArray *searchMutablArr = [NSMutableArray arrayWithArray:searchArr];
                for (NSString *searchStr in searchMutablArr) {
                    if ([key isEqualToString:searchStr]) {
                        [searchMutablArr removeObject:searchStr];
                        break;
                    };
                    
                }
                [searchMutablArr insertObject:key atIndex:0];
                searchArr = [searchMutablArr copy];
                [userDefaultes setObject:searchArr forKey:@"searchHis"];
                [userDefaultes synchronize];
            }
            
        }
        isSearchHistory = NO;
        isPeopleList = YES;
    }
    
    if (key && [key length] > 0) {
        
        if ([key isEqualToString:@"%"]) { // 此字符会导致服务端搜索异常，暂时客户端控制一下
            [MyUtils showAlertWithTitle:@"结果为空" message:nil];
            return;
        }
        
        NSDictionary *param = [NSDictionary dictionaryWithObject:key forKey:@"key"];
        
        ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
        alertView.isHasBtn = NO;
        [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"搜索中..."];
        [self.view addSubview:alertView];
        
        [CIBRequestOperationManager invokeAPI:@"searchAUv2" byMethod:@"POST" withParameters:param onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            isSearchHistory = NO;
            if ([responseCode isEqualToString:@"I00"])
            {
                [alertView removeFromSuperview];
                NSDictionary *responseDic = (NSDictionary *)responseInfo;
                NSString *resultCode = [responseDic objectForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"])
                {
                    NSDictionary *resultDic = [responseDic objectForKey:@"result"];
                    NSArray *appList = [resultDic objectForKey:@"webAppList"];
                    for (NSDictionary *appInfo in appList) {
                        NSMutableDictionary *cellInfo = [[NSMutableDictionary alloc] init];
                        
                        [cellInfo setObject:[appInfo objectForKey:@"appNo"] forKey:@"appNo"];
                        [cellInfo setObject:[appInfo objectForKey:@"appShowName"] forKey:@"appShowName"];
                        [cellInfo setObject:[appInfo objectForKey:@"appShowName"] forKey:@"name"];
                        [cellInfo setObject:[appInfo objectForKey:@"url"] forKey:@"url"];
                        
                        id imgAddress = [appInfo objectForKey:@"appIcon"];
                        if ([imgAddress isKindOfClass:[NSNull class]] && [imgAddress isEqual:[NSNull null]]) {
                            [cellInfo setObject:@"" forKey:@"imgAddress"];
                        }
                        else {
                            [cellInfo setObject:[NSString stringWithFormat:@"%@", imgAddress] forKey:@"imgAddress"];
                        }
                        [self.list addObject:cellInfo];
                        [self.applicationList addObject:cellInfo];
                    }
                    NSArray *userList = [resultDic objectForKey:@"userList"];
                    for (NSDictionary *userInfo in userList) {
                        
                        NSMutableDictionary *cellInfo = [[NSMutableDictionary alloc] init];
                        
                        [cellInfo setObject:kAppNoOfSearchedUser forKey:@"appNo"];
                        [cellInfo setObject:[userInfo objectForKey:@"USERNAME"] forKey:@"appShowName"];
                        [cellInfo setObject:[userInfo objectForKey:@"USERID"] forKey:@"notesId"];
                        id orgName =[userInfo objectForKey:@"ORGNAME"];
                        orgName=orgName==nil || [orgName isKindOfClass: [NSNull class]]?@"":orgName;
                        [cellInfo setObject:orgName forKey:@"orgName"];
                        
                        id imgAddress = [userInfo objectForKey:@"faceImg"];
                        if ([imgAddress isKindOfClass:[NSNull class]] && [imgAddress isEqual:[NSNull null]]) {
                            [cellInfo setObject:@"" forKey:@"imgAddress"];
                        }
                        else {
                            NSString *relativeAddress = [NSString stringWithFormat:@"%@", imgAddress];
                            NSString *baseURL = [URLAddressManager getBasicURLAddress];
                            NSString *fullAddress = [MyUtils combineURLWithBaseURL:baseURL andRelativeURL:relativeAddress];

                            [cellInfo setObject:fullAddress forKey:@"imgAddress"];
                        }
                        [self.list addObject:cellInfo];
                        [self.peopleList addObject:cellInfo];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self.resultTableView reloadData];

                    });
                                        }
                else {
                    NSString *resultInfo = [responseDic objectForKey:@"result"];
                    [MyUtils showAlertWithTitle:resultInfo message:nil];
                }
            }
            else {
                [alertView removeFromSuperview];
                [MyUtils showAlertWithTitle:responseInfo message:nil];
            }
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            isSearchHistory = YES;
            [alertView removeFromSuperview];
            [MyUtils showAlertWithTitle:responseInfo message:nil];
        }];
    }
    return;
}

- (NSString *)combineContactUserParamForURL:(NSString *)url {
    
    NSArray *urlArray = [url componentsSeparatedByString:@"#"];
    if (urlArray) {
        if ([urlArray count] != 2) {
            CIBLog(@"服务端返回的地址#位置和数目不对啊");
        }
        else {
            NSString *userToken = [AppInfoManager getValueForKey:kKeyOfUserToken forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
            NSString *deviceId = [AppInfoManager getDeviceID];
            NSString *userId = [AppInfoManager getUserID];
            NSString *userName = [AppInfoManager getUserName];
            NSString *orgId = [AppInfoManager getValueForKey:kKeyOfOrgID];
            
            NSString *firstPart = [urlArray objectAtIndex:0];
            // 检查前半部分最后一个字符是否为 ‘/’
            BOOL isLastCharDash = [[firstPart substringFromIndex:[firstPart length] - 1] isEqualToString:@"/"];
            if (isLastCharDash) {
                // 去掉'/'
                firstPart = [firstPart substringToIndex:[firstPart length] - 1];
                // 拼接
                firstPart = [NSString stringWithFormat:@"%@?usertoken=%@&deviceid=%@&userid=%@&notesid=%@&orgid=%@/", firstPart, userToken, deviceId, userId, userName, orgId];
            }
            else {
                firstPart = [NSString stringWithFormat:@"%@?usertoken=%@&deviceid=%@&userid=%@&notesid=%@&orgid=%@", firstPart, userToken, deviceId, userId, userName, orgId];
            }
            return [NSString stringWithFormat:@"%@#%@", firstPart, [urlArray objectAtIndex:1]];
        }
    }
    else {
        CIBLog(@"服务端返回的地址里面没有#");
    }
    
    return url;
}

// 点击搜索历史列表右侧的删除按钮（删除单元格，并删除NSUserDefaults中的历史记录）
-(void)deleteSearchHis:(UIButton *)sender{
    SearchResultCell *cell = (SearchResultCell *)[sender superview];
    NSIndexPath *indextPath = [self.resultTableView indexPathForCell:cell];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *searchArr = [userDefaults arrayForKey:@"searchHis"];
    NSMutableArray *searchMutablArr = [NSMutableArray arrayWithArray:searchArr];
    for (NSString *cellInfo in searchMutablArr) {
        if ([cell.textLabel.text isEqualToString:cellInfo]) {
            [searchMutablArr removeObject:cellInfo];
            break;
            
        }
        
    }
    self.searchHisArr = searchMutablArr;
    [userDefaults setObject:self.searchHisArr forKey:@"searchHis"];
    [userDefaults synchronize];
    [self tableView:self.resultTableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indextPath];
    
    [self.resultTableView reloadData];
}

// 点击联系人按钮
-(void)clickPeopleBtn{
    
    rBottomLine.hidden = YES;
    lBottomLine.hidden = NO;
    [peopleBtn setTitleColor:UIColorFromRGB(0x1277d4) forState:UIControlStateNormal];
    [applicationBtn setTitleColor:UIColorFromRGB(0x606060) forState:UIControlStateNormal];
    isPeopleList = YES;
    
    [self.resultTableView reloadData];
}

// 点击应用按钮
-(void)clickAppBtn{
    
    lBottomLine.hidden = YES;
    rBottomLine.hidden = NO;
    [rBottomLine setBackgroundColor:UIColorFromRGB(0x1277d4)];
    [applicationBtn setTitleColor:UIColorFromRGB(0x1277d4) forState:UIControlStateNormal];
    [peopleBtn setTitleColor:UIColorFromRGB(0x606060) forState:UIControlStateNormal];
    isPeopleList = NO;

    [self.resultTableView reloadData];
    
}
@end
