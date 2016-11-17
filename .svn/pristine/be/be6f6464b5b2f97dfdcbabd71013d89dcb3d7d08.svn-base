//
//  SearchViewController.h
//  CIBSafeBrowser
//
//  Created by cib on 15/3/10.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"
#import "iflyMSC/iflyMSC.h"

//forward declare
@class PopupView;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

static NSString *kAppNoOfSearchedUser = @"-9999";

@interface SearchViewController : UIViewController<IFlySpeechRecognizerDelegate,IFlyRecognizerViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSString *pcmFilePath;//音频文件路径
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;//带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象
@property (nonatomic, strong) PopupView *popUpView;
@property (nonatomic, strong) NSString * result;
@property (nonatomic, assign) BOOL isCanceled;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField; // 搜索框
@property (strong, nonatomic) IBOutlet UIButton *cancelButton; // 取消按钮
@property (strong, nonatomic) IBOutlet UITableView *resultTableView; // 结果列表

@property(nonatomic, assign) MainViewControllerState mainViewPreState;

@end
