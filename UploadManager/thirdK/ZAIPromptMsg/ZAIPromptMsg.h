//
//  ZAIMsgPromptView.h
//  ZAInsurance
//
//  Created by VincentHu on 15/7/3.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAIPromptMsg : UIView

+ (ZAIPromptMsg *)sharedInstance;
+ (ZAIPromptMsg *)showWithText:(NSString *)text;
+ (ZAIPromptMsg *)showWithText:(NSString *)text duration:(CGFloat)duration;
+ (ZAIPromptMsg *)showWithText:(NSString *)text topOffset:(CGFloat)topOffset;
+ (ZAIPromptMsg *)showWithText:(NSString *)text topOffset:(CGFloat)topOffset duration:(CGFloat)duration;
+ (ZAIPromptMsg *)showWithText:(NSString *)text bottomOffset:(CGFloat)bottomOffset;
+ (ZAIPromptMsg *)showWithText:(NSString *)text bottomOffset:(CGFloat)bottomOffset duration:(CGFloat)duration;
+ (ZAIPromptMsg *)showWithText:(NSString *)text inView:(UIView *)view orientationSensitive:(BOOL)orientationSensitive;

@end
