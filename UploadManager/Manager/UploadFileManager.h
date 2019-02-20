//
//  UploadFileManager.h
//  JavaScript
//
//  Created by chen on 19/1/28.
//  Copyright © 2019年 chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef void(^FinishJSCallBackBlcok)(id data);

@interface UploadFileManager : NSObject

@property (nonatomic, strong) id callbackData;
@property (nonatomic, copy) NSString *uploadType;
@property (nonatomic, copy) NSString *uploadURL;
@property (nonatomic, copy)FinishJSCallBackBlcok block;


+ (UploadFileManager *)shared;
- (void)uploadFileWithViewController:(UIViewController *)viewController finishJSCallBackBlock :(FinishJSCallBackBlcok)block;
@end
