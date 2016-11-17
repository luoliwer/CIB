//
//  CollectionFootView.h
//  CIBSafeBrowser
//
//  Created by wangzw on 16/1/4.
//  Copyright © 2016年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionFootView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UIView *advertismentView;
@property (strong, nonatomic) IBOutlet UIView *infoView;
//@property (strong, nonatomic) IBOutlet UIButton *settingBtn;
//@property (strong, nonatomic) IBOutlet UIButton *seachBtn;
//@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *spotArray;
@property (strong, nonatomic) IBOutlet UIButton *messageBtn;

@property (strong, nonatomic) UIScrollView *imageScrollView;

@property (strong, nonatomic) UIImageView *scrollViewBackground;
@end
