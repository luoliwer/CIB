//
//  FileCell.h
//  CIBSafeBrowser
//
//  Created by cib on 14/12/11.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadFile.h"

@interface FileCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *downloadTimeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (strong, nonatomic) IBOutlet UIButton *cellButtonSelect;


@property (assign, nonatomic) BOOL isSelect;
@property (strong, nonatomic) DownloadFile *file;

@end
