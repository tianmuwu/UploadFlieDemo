//
//  ViewController.m
//  UploadFlieDemo
//
//  Created by wotui on 19/1/30.
//  Copyright © 2019年 陈鹏飞. All rights reserved.
//

#import "ViewController.h"
#import "UploadFileManager.h"

@interface ViewController () <UIWebViewDelegate>

@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ViewController

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _webView.delegate = self;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* path = @"http://liao.unicornsocialmedia.cn?mobilenum=15736782777";
    //NSString* path = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    
    [self loadUrlString:path];
}

- (void)loadUrlString:(NSString *)str {
    
    [self.view addSubview:self.webView];
    NSString *encodedString = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *weburl = [NSURL URLWithString:encodedString];
    
    // 2. 把URL告诉给服务器,请求,从m.baidu.com请求数据
    NSURLRequest *request = [NSURLRequest requestWithURL:weburl];
    
    // 3. 发送请求给服务器
    [self.webView loadRequest:request];
}




 // 1 ：导入uploadFileManager  2:根据自己的需要创建webView    3:实现下面webview两个代理

#pragma webView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  
    NSLog(@"%@",webView.request.URL);
    // 拿到网页的实时url
    NSString *requestStr = [[webView.request.URL absoluteString] stringByRemovingPercentEncoding];
    if ([requestStr rangeOfString:@"http://liao.unicornsocialmedia.cn"].location !=NSNotFound) {
        
        self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        self.jsContext[@"needToBind()"] = self;
        self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
            context.exception = exceptionValue;
            NSLog(@"异常信息：%@", exceptionValue);
        };
    }
}

//js调用oc
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // 拿到网页的实时url
    NSString *requestStr = [[request.URL absoluteString] stringByRemovingPercentEncoding];
    if([requestStr rangeOfString:@"http://chat.unicornsocialmedia.cn"].location !=NSNotFound){
        
        NSArray *arr = [requestStr componentsSeparatedByString:@","];
        NSLog(@"%@",requestStr);
        if (arr != nil && arr.count >= 3) {
            
            [UploadFileManager shared].uploadType = arr[1];
            NSLog(@"上传类型 %@",[UploadFileManager shared].uploadType);
            // 拿到关键字符串，发送网络请求
            [UploadFileManager shared].uploadURL = arr[2];
            [[UploadFileManager shared] uploadFileWithViewController:self finishJSCallBackBlock:^(id data) {
                
                [self getCall:data];
            }];

        }
        return NO;
    }
    return YES;
}


//oc回调Js
- (void)getCall:(id)callBackData{
    // 之后在回调js的方法Callback把内容传出去
    JSValue *Callback = self.jsContext[@"callbackWithUploadMedia"];
    //传值给web端
    [Callback callWithArguments:@[callBackData]];
}



@end
