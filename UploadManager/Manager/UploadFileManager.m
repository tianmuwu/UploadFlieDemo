//
//  UploadFileManager.m
//  JavaScript
//
//  Created by chen on 19/1/28.
//  Copyright © 2019年 chen. All rights reserved.
//

#import "UploadFileManager.h"
#import "UpLoadUserpicTool.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "YYModel.h"
#import "UploadModel.h"

@interface UploadFileManager ()

@property (nonatomic, strong)UIViewController *viewController;
@end

//弱引用/强引用
#define WeakSelf(type)  __weak typeof(type) weak##type = type;
#define StrongSelf(type)  __strong typeof(type) type = weak##type;

@implementation UploadFileManager


+ (UploadFileManager *)shared
{
    static UploadFileManager *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (!manager) {
            manager = [[UploadFileManager alloc] init];
        }
    });
    return manager;
}


- (void)uploadFileWithViewController:(UIViewController *)viewController finishJSCallBackBlock:(FinishJSCallBackBlcok)block{
    
    
    if (viewController) {
        self.viewController = viewController;
    }
    if (block) {
        self.block = block;
    }

    WeakSelf(self);
    
    [[UpLoadUserpicTool shareManager]selectUserpicSourceWithType:self.uploadType WithViewController:self.viewController FinishSelectImageBlcok:^(UploadModel *model){
        StrongSelf(self);
        
        [self uploadImageAndMovieBaseModel:model];
        
    }];
}



//上传图片和视频
- (void)uploadImageAndMovieBaseModel:(UploadModel *)model {
    
    [self showLoadView];
    //获取文件的后缀名
    NSString *extension = [model.name componentsSeparatedByString:@"."].lastObject;
    
    //设置mimeType
    NSString *mimeType;
    if ([model.type isEqualToString:@"img"]) {
        
        mimeType = [NSString stringWithFormat:@"img/%@", extension];
    } else {
        
        mimeType = [NSString stringWithFormat:@"video/%@", extension];
    }
    
    //创建AFHTTPSessionManager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置响应文件类型为JSON类型
    manager.responseSerializer    = [AFJSONResponseSerializer serializer];
    
    //初始化requestSerializer
    manager.requestSerializer     = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = nil;
    
    //设置timeout
    [manager.requestSerializer setTimeoutInterval:20.0];
    
    //设置请求头类型
    [manager.requestSerializer setValue:@"form/data" forHTTPHeaderField:@"Content-Type"];
    
    //设置请求头, 授权码
    [manager.requestSerializer setValue:@"YgAhCMxEehT4N/DmhKkA/M0npN3KO0X8PMrNl17+hogw944GDGpzvypteMemdWb9nlzz7mk1jBa/0fpOtxeZUA==" forHTTPHeaderField:@"Authentication"];
    
    //上传服务器接口
    NSString *url = self.uploadURL;
    
    //开始上传
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error;
        NSString *formKey = @"files";
        
        BOOL success = [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.path] name:formKey fileName:model.name mimeType:mimeType error:&error];
        
        if (!success) {
            
            NSLog(@"appendPartWithFileURL error: %@", error);
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSLog(@"上传进度: %f", uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hideLoadView];
        NSLog(@"成功返回: %@", responseObject);
        //获取webView线程，因为js和oc绑定的函数里执行的代码不是在主线程里。
        
        NSString * json = [responseObject yy_modelToJSONString];
        NSMutableDictionary *jsondic = [self dictionaryWithJsonString:json];
        
        [jsondic setValue:model.type forKey:@"type"];
        [jsondic setValue:model.path forKey:@"path"];
        [jsondic setValue:@"200" forKey:@"status_code"];
        
        self.callbackData = jsondic;
        NSThread *webThread = [NSThread currentThread];
        [self performSelector:@selector(jsCall) onThread:webThread withObject:nil waitUntilDone:NO];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self hideLoadView];
        NSLog(@"上传失败: %@", error);
        if (error.code == NSURLErrorTimedOut) {
            self.callbackData = [NSString stringWithFormat:@"%@Type:%@Path:%@StatusCode:%d",error,model.type,model.path,408];
        }else{
            self.callbackData = [NSString stringWithFormat:@"%@Type:%@Path:%@StatusCode:%d",error,model.type,model.path,400];
        }
        
        NSThread *webThread = [NSThread currentThread];
        [self performSelector:@selector(jsCall) onThread:webThread withObject:nil waitUntilDone:NO];
        
    }];
}


- (void)jsCall{
    
    if (self.block) {
        self.block(self.callbackData);
    }
}


- (NSMutableDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}



- (void)showLoadView {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
}

- (void)hideLoadView{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:window animated:YES];
}

@end
