//
//  PhotoEventHandleUtils.h
//  demo
//
//  Created by cibdev-macmini-1 on 16/7/11.
//  Copyright © 2016年 Swy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoEventHandleUtils : NSObject

@property (nonatomic, assign) CGFloat pixelWidth;//压缩图片的宽度
@property (nonatomic, assign) CGFloat pixelHeight;//压缩图片的高度
@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) void (^takePhotoSuccess)(NSString *fileId, NSString *thumbnail);//拍摄照片成功
@property (nonatomic, strong) void (^takePhotoFailure)(NSString *flag, NSString *info);//拍摄照片失败

+ (instancetype)sharedPhotoEventHandleUtils;

- (BOOL)isCameraAvailable;

//打开照相机功能
- (void)openCameraInViewController:(UIViewController *)Vc;

//上传文件/图片
- (void)uploadFiles:(NSArray *)filesID
             noteId:(NSString *)noteId
            success:(void(^)(NSString *flag, NSString *info))success
            failure:(void(^)(NSString *flag, NSString *info))failure
           progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

//- (void)queryAuthoOfDocumentWithUri:(NSString *)uri
//                          parameter:(NSDictionary *)param
//                            success:(void(^)(NSString *filePath))succ
//                            failure:(void(^)(NSString *flag, NSString *info))fail;

//下载图片
- (void)downloadPhotoWithURI:(NSString *)uri
                   parameter:(NSDictionary *)parameter
                     success:(void(^)(NSString *picString))success
                     failure:(void(^)(NSString *flag, NSString *info))failure
                    progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

- (void)deletePhoto:(NSString *)fileID;

@end
