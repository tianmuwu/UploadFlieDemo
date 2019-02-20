//
//  UpLoadUserpicTool.m

//  Created by chen on 19/1/26.
//  Copyright © 2019年 chen. All rights reserved.
//

#import "UpLoadUserpicTool.h"
#import "AlertMananger.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZYQAssetPickerController.h"
#import "ZAIPromptMsg.h"

@interface UpLoadUserpicTool ()<UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ZYQAssetPickerControllerDelegate>


@property (nonatomic, strong) NSMutableArray  *imageArray;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, copy) FinishSelectImageBlcok imageBlock;

@end

#define PHOTOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"photoCache"]
#define VIDEOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"videoCache"]

//弱引用/强引用
#define WeakSelf(type)  __weak typeof(type) weak##type = type;
#define StrongSelf(type)  __strong typeof(type) type = weak##type;
@implementation UpLoadUserpicTool

+ (UpLoadUserpicTool *)shareManager
{
    static UpLoadUserpicTool *managerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        managerInstance = [[self alloc] init];
    });
    return managerInstance;
}

- (NSMutableArray *)imageArray{
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc]init];
    }
    return _imageArray;
}

- (void)selectUserpicSourceWithType:(NSString *)type WithViewController:(UIViewController *)viewController FinishSelectImageBlcok:(FinishSelectImageBlcok)finishSelectImageBlock 
{
    if (viewController) {
        self.viewController = viewController;
    }
    if (finishSelectImageBlock) {
        self.imageBlock = finishSelectImageBlock;
    }

    if ([type isEqualToString:@"all"]) {
        WeakSelf(self);
        AlertMananger *alert = [[AlertMananger shareManager] creatAlertWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet cancelTitle:@"取消" otherTitle:@"拍照",@"从相册选择",@"录像", nil];
        [alert showWithViewController:viewController IndexBlock:^(NSInteger index) {
            
            StrongSelf(self);
            if (index == 1) {
                
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])return;///<检测该设备是否支持拍摄
                UIImagePickerController* picker = [[UIImagePickerController alloc]init];///<图片选择控制器创建
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;///<设置数据来源为拍照
                picker.allowsEditing = NO;
                picker.delegate = self;///<代理设置
                
                [viewController presentViewController:picker animated:YES completion:nil];///<推出视图控制器
                
            }else if (index == 2){
        
                ZYQAssetPickerController *pickerController = [[ZYQAssetPickerController alloc] init];
                pickerController.maximumNumberOfSelection = 1;
                //    pickerController.nowCount = _imageArray.count;
                pickerController.assetsFilter = ZYQAssetsFilterAllAssets;
                pickerController.showEmptyGroups=NO;
                pickerController.delegate = self;
                pickerController.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    if ([(ZYQAsset*)evaluatedObject mediaType]==ZYQAssetMediaTypeVideo) {
                        NSTimeInterval duration = [(ZYQAsset*)evaluatedObject duration];
                        return duration >= 5;
                    } else {
                        return YES;
                    }
                }];
                
                [viewController presentViewController:pickerController animated:YES completion:nil];///<推出视图控制器
            }
            else if (index == 3){
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])return;///<检测该设备
                UIImagePickerController* picker = [[UIImagePickerController alloc]init];///<图片选择控制器创建
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
                picker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
                
                picker.videoQuality = UIImagePickerControllerQualityType640x480;
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                picker.allowsEditing = YES;
                picker.delegate = self;///<代理设置
                picker.videoMaximumDuration = 10;
                [viewController presentViewController:picker animated:YES completion:nil];///<推出视图控制器
            }
        }];
    }else if([type isEqualToString:@"image"]){
        WeakSelf(self);
        AlertMananger *alert = [[AlertMananger shareManager] creatAlertWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet cancelTitle:@"取消" otherTitle:@"拍照",@"从相册选择", nil];
        [alert showWithViewController:viewController IndexBlock:^(NSInteger index) {
            
            StrongSelf(self);
            if (index == 1) {
                
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])return;///<检测该设备是否支持拍摄
                UIImagePickerController* picker = [[UIImagePickerController alloc]init];///<图片选择控制器创建
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;///<设置数据来源为拍照
                picker.allowsEditing = NO;
                picker.delegate = self;///<代理设置
                
                [viewController presentViewController:picker animated:YES completion:nil];///<推出视图控制器
                
            }else if (index == 2){
                
                ZYQAssetPickerController *pickerController = [[ZYQAssetPickerController alloc] init];
                pickerController.maximumNumberOfSelection = 1;
                //    pickerController.nowCount = _imageArray.count;
                pickerController.assetsFilter = ZYQAssetsFilterAllPhotos;
                pickerController.showEmptyGroups=NO;
                pickerController.delegate = self;
                [viewController presentViewController:pickerController animated:YES completion:nil];///<推出视图控制器
            }
        }];

    }else if([type isEqualToString:@"video"]){
        WeakSelf(self);
        AlertMananger *alert = [[AlertMananger shareManager] creatAlertWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet cancelTitle:@"取消" otherTitle:@"录像",@"从视频库选择", nil];
        [alert showWithViewController:viewController IndexBlock:^(NSInteger index) {
            
            StrongSelf(self);
            if (index == 1) {
                
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])return;///<检测该设备
                UIImagePickerController* picker = [[UIImagePickerController alloc]init];///<图片选择控制器创建
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
                picker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
                picker.videoMaximumDuration = 10;
                picker.videoQuality = UIImagePickerControllerQualityType640x480;
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                picker.allowsEditing = YES;
                picker.delegate = self;///<代理设置
                [viewController presentViewController:picker animated:YES completion:nil];///<推出视图控制器

                
            }else if (index == 2){
                
                UIImagePickerController* picker = [[UIImagePickerController alloc]init];///<图片选择控制器创建
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.mediaTypes = @[(NSString *)kUTTypeMovie];
                picker.allowsEditing = NO;
                picker.delegate = self;
                [viewController presentViewController:picker animated:YES completion:nil];///<推出视图控制器
            }
          
        }];

    }
    

}

- (void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets.count == 0) {
        [ZAIPromptMsg showWithText:@"您没有选择任何文件"];
        return;
    }
    WeakSelf(self);
     if ([(ZYQAsset*)assets[0] mediaType]==ZYQAssetMediaTypeVideo) {
         
        ZYQAsset *asset = assets[0];
        [self uploadVideoModel:asset];
         
     }else{
         
         ZYQAsset *asset = assets[0];
        
         [asset setGetFullScreenImage:^(UIImage *result){
             StrongSelf(self);
             if (result == nil) {
                 [ZAIPromptMsg showWithText:@"照片不符合上传规格"];
                 return ;
             }else{
            
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self uploadImgModel:result];
                 });
             }
             
         }];

         
       /**  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            StrongSelf(self);
                            for (int i=0; i<assets.count; i++)
                            {
        
                                ZYQAsset *asset = assets[i];
        
                                [asset setGetFullScreenImage:^(UIImage *result){
        
                                    if (result == nil) {
                                        [ZAIPromptMsg showWithText:@"照片不符合上传规格"];
                                        return ;
                                    }
                                    if(self.imageArray.count >9){
                                        [ZAIPromptMsg showWithText:@"您一次只能上传9张照片"];
                                        NSLog(@"---%ld",self.imageArray.count);
                                        return ;
                                    }else{
                                        [self.imageArray addObject:result];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            [self uploadImgModel:result];
                                        });
                                    }
                                    
                                    NSLog(@"---%ld",self.imageArray.count);
                                    
                                }];
                                
                            }
                        });**/
     }
    
}

 //生成上传图片model
- (void)uploadImgModel:(UIImage *)image{
    //获取图片名称
    NSLog(@"获取图片名称");
    NSString *imageName = [self getImageNameBaseCurrentTime];
    NSLog(@"图片名称: %@", imageName);
    
    //将图片存入缓存
    NSLog(@"将图片写入缓存");
    [self saveImage:image
        toCachePath:[PHOTOCACHEPATH stringByAppendingPathComponent:imageName]];
    
    //创建uploadModel
    NSLog(@"创建model");
    UploadModel *model = [[UploadModel alloc] init];
    
    model.path       = [PHOTOCACHEPATH stringByAppendingPathComponent:imageName];
    model.name       = imageName;
    model.type       = @"img";
    
    if (self.imageBlock) {
        self.imageBlock(model);
    }
}

- (void)getVideoModel:(id)videoPath{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    
        //生成视频名称
        NSString *mediaName = [self getVideoNameBaseCurrentTime];
        NSLog(@"mediaName: %@", mediaName);
        
        //将视频存入缓存
        NSLog(@"将视频存入缓存");
        [self saveVideoFromPath:videoPath toCachePath:[VIDEOCACHEPATH stringByAppendingPathComponent:mediaName]];
        
        CGFloat size = [self getVideoLength:videoPath];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            if(size>10){
                    NSString *message;
                    message = @"视频超过10s，不能上传，抱歉。";
                    [ZAIPromptMsg showWithText:message duration:1];
                    [[NSFileManager defaultManager] removeItemAtPath:[VIDEOCACHEPATH stringByAppendingPathComponent:mediaName] error:nil];//取消之后就删除，以免占用手机硬盘空间
                    return;
                }else{
                //创建uploadmodel
                UploadModel *model = [[UploadModel alloc] init];
                model.path       = [VIDEOCACHEPATH stringByAppendingPathComponent:mediaName];
                model.name       = mediaName;
                model.type       = @"video";
                if (self.imageBlock) {
                    self.imageBlock(model);
                }
            }
                
        });
        
    });

}

//上传视频model
- (void)uploadVideoModel:(ZYQAsset *)asset{
    WeakSelf(self);
    //ios9之前
    if ([asset.originAsset isKindOfClass:[ALAsset class]]) {
        
        NSURL *url = [(ALAsset *)asset.originAsset valueForProperty:ALAssetPropertyAssetURL];
        [self getVideoModel:url];
        //ios9之后
    }else if ([asset.originAsset isKindOfClass:[PHAsset class]]){
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        StrongSelf(self);
        [manager requestAVAssetForVideo:(PHAsset *)asset.originAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            
            NSURL *url = urlAsset.URL;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self getVideoModel:url];
            });
            
            NSLog(@"VideoUrl————————%@",url);
        }];
    }

}

#pragma mark - 相册/相机回调  显示所有的照片，或者拍照选取的照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //获取用户选择或拍摄的是照片还是视频
    NSString *mediaType = info[UIImagePickerControllerMediaType];
   
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        //获取编辑后的照片
        NSLog(@"获取编辑后的好片");
        UIImage *tempImage = info[UIImagePickerControllerOriginalImage];
        
        //将照片存入相册
        if (tempImage) {
            
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                
                //将照片存入相册
                NSLog(@"将照片存入相册");
                UIImageWriteToSavedPhotosAlbum(tempImage, self, nil, nil);
            }
            
            [self uploadImgModel:tempImage];
        }
    }
    
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            //如果是拍摄的视频, 则把视频保存在系统多媒体库中
            NSLog(@"video path: %@", info[UIImagePickerControllerMediaURL]);
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:info[UIImagePickerControllerMediaURL] completionBlock:^(NSURL *assetURL, NSError *error) {
                
                if (!error) {
                    
                    NSLog(@"视频保存成功");
                } else {
                    
                    NSLog(@"视频保存失败");
                }
            }];
        }
        
        [self getVideoModel:info [UIImagePickerControllerMediaURL]];
        
    }
}

//  取消选择 返回当前试图
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


//将Image保存到缓存路径中
- (void)saveImage:(UIImage *)image toCachePath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:PHOTOCACHEPATH]) {
        
        NSLog(@"路径不存在, 创建路径");
        [fileManager createDirectoryAtPath:PHOTOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else {
        
        NSLog(@"路径存在");
    }
    
    //[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
}

//将视频保存到缓存路径中
- (void)saveVideoFromPath:(NSString *)videoPath toCachePath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:VIDEOCACHEPATH]) {
        
        NSLog(@"路径不存在, 创建路径");
        [fileManager createDirectoryAtPath:VIDEOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else {
        
        NSLog(@"路径存在");
    }
    
    NSError *error;
    [fileManager copyItemAtPath:videoPath toPath:path error:&error];
    if (error) {
        
        NSLog(@"文件保存到缓存失败");
    }
}

//此方法可以获取视频文件的时长。
- (CGFloat) getVideoLength:(NSURL *)URL
{
    
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}

//以当前时间合成图片名称
- (NSString *)getImageNameBaseCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".JPG"];
}

//以当前时间合成视频名称
- (NSString *)getVideoNameBaseCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".MOV"];
}


@end
