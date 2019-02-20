//
//  AlertMananger.m
//  AlertController
//
//  Created by chen on 19/1/27.
//  Copyright © 2019年 chen. All rights reserved.
//

#import "AlertMananger.h"

@interface AlertMananger ()

@property(nonatomic, strong)UIAlertController *alertCol;
@property(nonatomic, strong)NSMutableArray *actionTitles;
@property(nonatomic,copy)AlertIndexBlock indexBlock;

@end

@implementation AlertMananger


+ (AlertMananger *)shareManager
{
    static AlertMananger *managerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        managerInstance = [[self alloc] init];
    });
    return managerInstance;
}

- (AlertMananger *)creatAlertWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle cancelTitle:(NSString *)canceTitle otherTitle:(NSString *)otherTitle,...NS_REQUIRES_NIL_TERMINATION{
    
    self.alertCol = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    NSString *actionTitle = nil;
    va_list args;//用于指向第一个参数
    self.actionTitles = [NSMutableArray array];
    [self.actionTitles addObject:canceTitle];
    if (otherTitle) {
        [self.actionTitles addObject:otherTitle];
        va_start(args, otherTitle);//对args进行初始化，让它指向可变参数表里面的第一个参数
        while ((actionTitle = va_arg(args, NSString*))) {
            
            [self.actionTitles addObject:actionTitle];
            
        }
        va_end(args);
    }
    [self buildCancelAction];
    [self buildOtherAction];
    
    return [AlertMananger shareManager];
}

- (void)buildCancelAction{
    
    NSString *cancelTitle = self.actionTitles[0];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.indexBlock(0);
        
    }];
    [self.alertCol addAction:cancelAction];
    
}

- (void)buildOtherAction{
    
    for (int i = 0 ; i < self.actionTitles.count; i++) {
        if (i == 0)continue;
        NSString *actionTitle = self.actionTitles[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (self.indexBlock) {
                
                self.indexBlock(i);
            }
            
        }];
        
        [self.alertCol addAction:action];
    }
    
}

- (void)showWithViewController:(UIViewController *)viewController IndexBlock:(AlertIndexBlock)indexBlock{
    
    if (indexBlock) {
        
        self.indexBlock = indexBlock;
        
    }
    
    [viewController presentViewController:self.alertCol animated:YES completion:^{
        
    }];
}



@end
