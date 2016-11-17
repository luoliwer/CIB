//
//  PhotoEventHandleUtils.m
//  demo
//
//  Created by cibdev-macmini-1 on 16/7/11.
//  Copyright © 2016年 Swy. All rights reserved.
//

#import "PhotoEventHandleUtils.h"
#import "ZipArchive.h"
#import <CIBBaseSDK/CIBFileOperationManager.h>
#import <CIBBaseSDK/CIBRequestOperationManager.h>
#import "GTMBase64.h"
#import "ImageCropView.h"
#import <AVFoundation/AVFoundation.h>
#import <CIBBaseSDK/AppInfoManager.h>

@interface PhotoEventHandleUtils ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController *_imagePickerController;
}
@end

static PhotoEventHandleUtils *_sharedPhotoEventHandleUtilsInstance;

@implementation PhotoEventHandleUtils

- (instancetype)init
{
    if (self = [super init]) {
        [self initImagePickViewController];
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGFloat rate = size.width / size.height;
        //默认压缩图片的宽高度
        _pixelWidth = 40;
        _pixelHeight = _pixelWidth / rate;
        _fileName = @"defaultImage.jpg";
    }
    return self;
}

- (void)initImagePickViewController
{
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePickerController.delegate = self;
}

- (void)dismissImagePickerViewController
{
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


/**
 *  单例
 */
+ (instancetype)sharedPhotoEventHandleUtils
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPhotoEventHandleUtilsInstance = [[PhotoEventHandleUtils alloc] init];
    });
    return _sharedPhotoEventHandleUtilsInstance;
}

#pragma mark -- 拍摄照片以及压缩照片处理

#pragma mark -- 判断相机是否授权
- (BOOL)isCameraAvailable
{
    AVAuthorizationStatus authStauts = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStauts == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

- (void)openCameraInViewController:(UIViewController *)Vc
{
    if (!_imagePickerController) {
        [self initImagePickViewController];
    }
    [Vc presentViewController:_imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //获取拍摄的图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    image = [image fixOrientation];
    
    //将图片保存在本地
    CGSize size = CGSizeMake(_pixelWidth, _pixelHeight);
    UIImage *scaleImage = [self originImage:image scaleToSize:size];
    
    NSString *pixelImgStr = [self pixelPhotoToBase64:UIImageJPEGRepresentation(scaleImage, 0.01)];
    BOOL succ = [self saveImageToLocal:image fileName:_fileName];
    
    if (succ) {
        NSLog(@"图片文件名称：%@", _fileName);
        _takePhotoSuccess(_fileName, pixelImgStr);
    } else {
        _takePhotoFailure(@"-1", @"保存失败");
    }
    
    //将imagepickercontroller移除
    [self dismissImagePickerViewController];
}


//图片压缩处理
- (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size
{
    //计算出image的压缩尺寸
    CGSize newSize;
    if (image.size.height / image.size.width > 1) {
        newSize.height = size.height;
        newSize.width = size.height / image.size.height * image.size.width;
    } else if (image.size.height / image.size.width < 1){
        newSize.height = size.width / image.size.width * image.size.height;
        newSize.width = size.width;
    } else {
        newSize = size;
    }
    
    //创建一个bitmap的context
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    
    //绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    //从当前imagecontext中获取到image
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭context
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (NSString *)filePath
{
    //获取沙盒路径
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *appId = [AppInfoManager getValueForKey:kKeyOfUserName];
    //构建文件夹路径
    NSString *directoryPath = [NSString stringWithFormat:@"%@/%@", Path, appId];
    
    return directoryPath;
}

//保存图片到本地沙盒
- (BOOL)saveImageToLocal:(UIImage *)image fileName:(NSString *)fileName
{
    //构建文件夹路径
    NSString *directoryPath = [self filePath];
    //判断该文件夹是否存在
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL createSuc = NO;
    if (![manager fileExistsAtPath:directoryPath]) {
        createSuc = [manager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        createSuc = YES;
    }
    
    //创建文件夹成功
    if (createSuc) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        //返回是否保存
        return [UIImageJPEGRepresentation(image, 0.01) writeToFile:filePath atomically:YES];
    }
    
    return NO;
}

//将缩略图加密成base64
- (NSString *)pixelPhotoToBase64:(NSData *)data
{
    NSString *base64Str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithFormat:@"data:image/jpg;base64,%@", base64Str];
}

#pragma mark -- 上传文件以及压缩文件处理

- (void)uploadFiles:(NSArray *)filesID
             noteId:(NSString *)noteId
            success:(void(^)(NSString *flag, NSString *info))success
            failure:(void(^)(NSString *flag, NSString *info))failure
           progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
{
    BOOL zipSuc = [self zips:filesID];//打包文件
    
    NSDictionary *param = @{@"notesid":noteId};
    
    if (zipSuc) {//打包成功
        
        //获取沙盒中文件夹路径
        NSString *directoryPath = [self filePath];
        
        //打包文件路径
        NSString *zipFilePath =[NSString stringWithFormat:@"%@/photoes.zip", directoryPath];
        
        //获取对应文件的数据
        NSData *data = [NSData dataWithContentsOfFile:zipFilePath];
        
        if (data.bytes > 0) {//判断对应文件是否为空
            //调用上传文件接口
            [CIBFileOperationManager uploadFileAtPath:zipFilePath withURI:@"zxuf" andParameter:param success:^(NSString *responseCode, NSString *responseInfo) {
                success(responseCode, responseInfo);
                //上传成功，删除本地压缩文件
                [self deleteZipFile:zipFilePath];
            } failure:^(NSString *responseCode, NSString *responseInfo) {
                failure(responseCode, responseInfo);
            } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                
            }];
        } else {
            failure(@"-10002", @"打包文件无数据");
        }
    } else {//打包失败
        failure(@"-10001", @"打包文件失败");
    }
}

//压缩图片文件成zip包文件
- (BOOL)zips:(NSArray *)filesID
{
    //获取沙盒路径
    NSString *docPath = [self filePath];
    NSString *directoryPath =[NSString stringWithFormat:@"%@", docPath];
    //判断该文件夹是否存在
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL createSuc = NO;
    if (![manager fileExistsAtPath:directoryPath]) {
        createSuc = [manager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        createSuc = YES;
    }
    
    if (createSuc) {
        NSString *zipFilePath = [directoryPath stringByAppendingPathComponent:@"photoes.zip"];
        //实例化压缩文档
        ZipArchive *archive = [[ZipArchive alloc] init];
        //创建文件
        [archive CreateZipFile2:zipFilePath];
        
        //从文件id数组去本地沙盒中获取图片路径
        [filesID enumerateObjectsUsingBlock:^(NSString *fileId, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:fileId];
            
            [archive addFileToZip:filePath newname:fileId];
        }];
        
        //关闭
        return [archive CloseZipFile2];
    }
    return NO;
}

//删除压缩文件
- (BOOL)deleteZipFile:(NSString *)zipFilePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL exist = [manager fileExistsAtPath:zipFilePath];
    if (exist) {
        NSError *error = nil;
        [manager removeItemAtPath:zipFilePath error:&error];
        if (!error) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

#pragma mark -- 删除照片
- (void)deletePhoto:(NSString *)fileID
{
    //获取沙盒路径
    NSString *docPath = [self filePath];
    //文件路径
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, fileID];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    //删除文件
    if ([manager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [manager removeItemAtPath:filePath error:&error];
    }
}

#pragma mark -- 下载图片
//- (void)queryAuthoOfDocumentWithUri:(NSString *)uri
//                          parameter:(NSDictionary *)param
//                            success:(void(^)(NSString *filePath))succ
//                            failure:(void(^)(NSString *flag, NSString *info))fail
//{
//    [CIBRequestOperationManager invokeAPI:uri byMethod:@"POST" withParameters:param onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
//        if ([responseCode isEqualToString:@"I00"]) {
//            NSDictionary *result = [responseInfo valueForKey:@"result"];
//            NSString *fileId = [result valueForKey:@"sqwjzj"];
//            
//            NSMutableDictionary *downParam = [NSMutableDictionary dictionaryWithDictionary:param];
//            [downParam removeObjectForKey:@"sqdabh"];
//            
//            if (!fileId) {
//                fileId = @"";
//            }
//            
//            fileId = @"56351756C0D3482CB660207C260AA56A";
//            
//            [downParam setValue:fileId forKey:@"sqwjzj"];
//            //查看授权档案成功回调后操作
//            //判断本地是否存在当前需要下载的文档
//            //获取沙盒路径
//            NSString *docPath = [self filePath];
//            NSString *directoryPath =[NSString stringWithFormat:@"%@", docPath];
//            //判断该文件夹是否存在
//            NSFileManager *manager = [NSFileManager defaultManager];
//            BOOL createSuc = NO;
//            if (![manager fileExistsAtPath:directoryPath]) {
//                createSuc = [manager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
//            } else {
//                createSuc = YES;
//            }
//            
//            NSString *fileName = [NSString stringWithFormat:@"%@.pdf", fileId];
//            NSString *pdfPath = [directoryPath stringByAppendingPathComponent:fileName];
//            //如果存在，则直接返回文件路径
//            //如果不存在，调用下载文件接口，成功后保存本地，返回其保存路径
//            if ([manager fileExistsAtPath:pdfPath]) {
//                succ(pdfPath);
//            } else {
//                [self downloadPhotoWithURI:@"zxdf" parameter:downParam success:^(NSString *picString) {
//                    succ(picString);
//                } failure:^(NSString *flag, NSString *info) {
//                    
//                } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//                    
//                }];
//            }
//        }
//        
//    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
//        fail(responseCode, responseInfo);
//    }];
//}


- (void)downloadPhotoWithURI:(NSString *)uri
                   parameter:(NSDictionary *)parameter
                     success:(void(^)(NSString *picString))success
                     failure:(void(^)(NSString *flag, NSString *info))failure
                    progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
{
    [CIBFileOperationManager downloadFileWithURI:uri andParameter:parameter success:^(NSDictionary *responseHeader, NSData *responseBody) {
        
        //获取沙盒路径
        NSString *docPath = [self filePath];
        
        //判断本地是否存在当前需要下载的文档
        //获取沙盒路径
        NSString *directoryPath =[NSString stringWithFormat:@"%@", docPath];
        //判断该文件夹是否存在
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL createSuc = NO;
        if (![manager fileExistsAtPath:directoryPath]) {
            createSuc = [manager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            createSuc = YES;
        }
        
        NSString *fileId = [NSString stringWithFormat:@"%@.pdf", [parameter valueForKey:@"sqwjzj"]];
        
        //文件路径
        NSString *pdfPath = [docPath stringByAppendingPathComponent:fileId];
        
        //存在 删除
        if ([manager fileExistsAtPath:pdfPath]) {
            [manager removeItemAtPath:pdfPath error:nil];
        }
        //不存在 保存
        BOOL saved = [responseBody writeToFile:pdfPath atomically:YES];
        
        if (saved) {
            success(pdfPath);
        } else {
            success(@"保存失败");
        }
        
    } failure:^(NSString *responseCode, NSString *responseInfo) {
        failure(responseCode, responseInfo);
    } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
    } header:^(NSDictionary *responseHeader) {
        
    }];
}

@end
