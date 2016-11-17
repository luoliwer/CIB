//
//  UserInfoViewController.m
//  CIBSafeBrowser
//
//  Created by wangzw on 16/3/31.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UIImageView+WebCache.h"
#import <CIBBaseSDK/CIBRequestOperationManager.h>


#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MyUtils.h"
#import "Chatter.h"
#import "OpenChatController.h"
#import "Message.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "MessagesController.h"

#import "ImageAlertView.h"
#import "GTMBase64.h"


@interface UserInfoViewController ()<ABNewPersonViewControllerDelegate,UIAlertViewDelegate,ABPeoplePickerNavigationControllerDelegate>{
     NSString *teleNumber; // 可能出现的电话号码
}
- (IBAction)backPress:(id)sender;
- (IBAction)sendMsgBtn:(id)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *orgNameWidthConstraint;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendMsgBtn.layer.cornerRadius=6.0;
    self.sendMsgBtn.layer.borderColor=[[UIColor blueColor] CGColor];
    self.sendMsgBtn.layer.borderWidth=1.0;
    
    self.orgNameWidthConstraint.constant=[[UIScreen mainScreen] bounds].size.width-40;
    
    
    //为电话号码增加手势
    UITapGestureRecognizer* pressDownGes =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callPhoen:)];
    self.phoneNOLabel.userInteractionEnabled=YES;
    [self.phoneNOLabel addGestureRecognizer:pressDownGes];
   
}
- (void)callPhoen:(UITapGestureRecognizer *)tap
{
    NSLog(@"拨打电话啦啦。。。。");
    NSString *teleNum = self.phoneNOLabel.text;
    if([teleNum isEqualToString:@""]){
        return;
    }
    NSString *msg = [NSString stringWithFormat:@"这是一个电话号码，您可以"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:teleNum message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", @"发送短信", @"添加到手机通讯录", @"复制",nil];
    alertView.tag = 8001;
    [alertView show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 点击电话号码后的alert view
    if (alertView.tag == 8001) {
        // buttonIndex从0到4分别是：取消，呼叫，发送短信，添加到手机通讯录和复制
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                NSURL *dialURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", alertView.title]];
                [[UIApplication sharedApplication] openURL:dialURL];
            }
                break;
            case 2:
            {
                NSURL *dialURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", alertView.title]];
                [[UIApplication sharedApplication] openURL:dialURL];
            }
                break;
            case 3:
                // 添加到手机通讯录
            {
                // 首先选择是新建联系人还是添加到现有联系人
                UIAlertView *nextAlertView = [[UIAlertView alloc] initWithTitle:alertView.title message:@"是一个电话号码，你可以" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"创建新联系人", @"添加到现有联系人", nil];
                nextAlertView.tag = 8002;
                [nextAlertView show];
            }
                break;
            case 4:
            {
                [UIPasteboard generalPasteboard].string = alertView.title;
            }
                break;
            default:
                break;
        }
    }
    // 点击添加到通讯录的alert view
    else if (alertView.tag == 8002) {
        // buttonIndex从0到2分别是：取消，创建新联系人和添加到现有联系人
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                ABNewPersonViewController *newPersonVC  = [[ABNewPersonViewController alloc] init];
                newPersonVC.newPersonViewDelegate = self;
                UINavigationController *navCtrlr = [[UINavigationController alloc] initWithRootViewController:newPersonVC];
                // 构造要显示的联系人对象
                CFErrorRef error = NULL;
                ABRecordRef personRef = ABPersonCreate();
                // 电话号码属于具有多个值的项
                ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                // 设置联系人电话值
                ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(alertView.title), kABPersonPhoneMobileLabel, NULL);
                ABRecordSetValue(personRef, kABPersonPhoneProperty, multi, &error);
                
                newPersonVC.displayedPerson = personRef;
                [self presentViewController:navCtrlr animated:YES completion:nil];
                CFRelease(multi);
                CFRelease(personRef);
            }
                break;
            case 2:
            {
                ABPeoplePickerNavigationController *peoplePickerNavCtrlr = [[ABPeoplePickerNavigationController alloc] init];
                if (![MyUtils isSystemVersionBelowEight]) {
                    peoplePickerNavCtrlr.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:true];
                }
                peoplePickerNavCtrlr.peoplePickerDelegate = self;
                // 暂存一下电话号码
                teleNumber = alertView.title;
                [self presentViewController:peoplePickerNavCtrlr animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }
}
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    [newPersonView.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    
    // 添加本次获取到的电话号码
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutableCopy (ABRecordCopyValue(person, kABPersonPhoneProperty));
    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(teleNumber), kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone,nil);
    ABAddressBookHasUnsavedChanges(peoplePicker.addressBook);
    
    ABNewPersonViewController *vc = [[ABNewPersonViewController alloc] init];
    vc.displayedPerson = person;
    vc.newPersonViewDelegate = self;
    UINavigationController *navCtrlr = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (multiPhone)
        CFRelease(multiPhone);
    
    // 由于ABPeoplePickerNavigationController会自动的pop掉所有view，因此延时处理ABNewPersonViewController的弹出。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:navCtrlr animated:YES completion:nil];
    });
    
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)backPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)sendMsgBtn:(id)sender {
    Chatter *chat = [[Chatter alloc] init];
    chat.chatterId=self.notesIdLabel.text;
    chat.chatterName=self.userNameLabel.text;
    [[[OpenChatController alloc] init] updateContact:chat];
    //设置消息
    Message *msg = [[Message alloc] init];
    msg.msgFromerId = chat.chatterId;
    msg.msgFromerName = chat.chatterName;
    NSString *toID = [AppInfoManager getUserName];
    NSString *toName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
    msg.msgToId = toID;
    msg.msgToName = toName;
    
    MessagesController *msgController = [[MessagesController alloc] init];
    msgController.msg = msg;
    msgController.backToViewControllerName = @"NewsListController";
    msgController.fromHere=@"userInfo";
//    [self.navigationController pushViewController:msgController animated:YES];
    [self presentViewController:msgController animated:YES completion:^{
    }];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *param = [NSDictionary dictionaryWithObject:self.notesId forKey:@"notesid"];
        ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
        alertView.isHasBtn = NO;
        [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在请求数据..."];
        [self.view addSubview:alertView];
        [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:param onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            [alertView removeFromSuperview];
            if([responseCode isEqualToString:@"I00"]){
                NSDictionary* resourceInfo = (NSDictionary*)responseInfo;
                if([[resourceInfo objectForKey:@"resultCode"] isEqualToString:@"0"]){
                    NSArray* userInfo = [resourceInfo objectForKey:@"result"];
                    [self performSelectorOnMainThread:@selector(refreshData:) withObject:userInfo[0] waitUntilDone:NO];
                }
            }
           
            
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            [alertView removeFromSuperview];
             NSLog(@"获取个人详情失败。。。。%@",responseInfo);
        }];
    });
}
-(void) refreshData:(NSDictionary*) data{
    self.headImageView.layer.cornerRadius=40.0;
    self.headImageView.layer.masksToBounds=YES;
    id headData=[data objectForKey:@"PICSTRING"];
    if(headData!=nil && ![headData isKindOfClass:[NSNull class]]){
        NSData *picData = [GTMBase64 decodeString:headData];
        UIImage *image = [UIImage imageWithData:picData];
        self.headImageView.image = image;
    }else {
         [self.headImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
    }
    id notesId = [data objectForKey:@"NOTESID"];
    notesId=notesId==nil || [notesId isKindOfClass:[NSNull class]]?@"":notesId;
    
    id username = [data objectForKey:@"USERNAME"];
    username=username==nil || [username isKindOfClass:[NSNull class]]?@"":username;
    
    id orgName = [data objectForKey:@"ORGNAME"];
    orgName=orgName==nil || [orgName isKindOfClass:[NSNull class]]?@"":orgName;
    
    id jobTitle = [data objectForKey:@"JOBTITLE"];
    jobTitle=jobTitle==nil || [jobTitle isKindOfClass:[NSNull class]]?@"":jobTitle;
    
    id mobile = [data objectForKey:@"MOBILE"];
    mobile=mobile==nil || [mobile isKindOfClass:[NSNull class]]?@"":mobile;
    
    id mail = [data objectForKey:@"MAIL"];
    mail=mail==nil || [mail isKindOfClass:[NSNull class]]?@"":mail;
    
    self.notesIdLabel.text=notesId;
    self.userNameLabel.text=username;
    self.orgNameLabel.text=orgName;
    self.jobTitleLabel.text=jobTitle;
    self.emailLabel.text=mail;
    
    //添加下划线
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:mobile];
    NSRange mobileRange = {0,[attrString length]};
    [attrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:mobileRange];
    self.phoneNOLabel.attributedText=attrString;
    
    
}
@end
