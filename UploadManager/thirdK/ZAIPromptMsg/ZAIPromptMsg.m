//
//  ZAIMsgPromptView.m
//  ZAInsurance
//
//  Created by VincentHu on 15/7/3.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAIPromptMsg.h"

static CGFloat Default_Display_Duration = 1.0f;
static CGFloat Default_Font_Size = 17.0f;
static CGFloat Default_View_Radius = 8.0f;
static CGFloat Default_View_Alpha  = 0.7f;

@interface ZAIPromptMsg()

@property (nonatomic, assign)BOOL    orientationSensitive;
@property (nonatomic, assign)BOOL    isZoomMax;
@property (nonatomic, assign)CGFloat promptFontSize;
@property (nonatomic, assign)CGFloat promptRadius;
@property (nonatomic, assign)CGFloat promptAlpha;

@property (nonatomic, strong)UIButton *contentView;
@property (nonatomic, strong)UILabel  *msgLable;
@property (nonatomic, assign)CGFloat  duration;
@property (nonatomic, assign)CGFloat  topMargin;
@property (nonatomic, assign)CGFloat  bottomMargin;
@property (nonatomic, assign)UIViewAutoresizing viewAutoresizingMask;

@end

@implementation ZAIPromptMsg

+ (ZAIPromptMsg *)sharedInstance
{
    static ZAIPromptMsg *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    if (self = [super init])
    {
        CGSize textSize = CGSizeMake(150, 80);
        _contentView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
        _contentView.layer.cornerRadius = Default_View_Radius;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [_contentView addTarget:self action:@selector(hideAnimation) forControlEvents:UIControlEventTouchUpInside];
        _contentView.alpha = 0;
        
        _msgLable = [[UILabel alloc] initWithFrame:_contentView.frame];
        _msgLable.numberOfLines = 0;
        _msgLable.backgroundColor = [UIColor clearColor];
        _msgLable.textColor = [UIColor whiteColor];
        _msgLable.textAlignment = NSTextAlignmentCenter;
        _msgLable.font = [UIFont boldSystemFontOfSize:Default_Font_Size];
        [_contentView addSubview:_msgLable];
        
        _duration = Default_Display_Duration;
        self.orientationSensitive = NO;
        self.isZoomMax = NO;
        self.promptFontSize = Default_Font_Size;
        self.promptRadius = Default_View_Radius;
        self.promptAlpha = Default_View_Alpha;
    }
    return self;
}


#pragma mark API
+ (ZAIPromptMsg *)showWithText:(NSString *)text duration:(CGFloat)duration
{
    ZAIPromptMsg * toast = [ZAIPromptMsg sharedInstance];
    [toast setText:text];
    [toast setDuration:duration];
    [toast showToast];
    return toast;
}

+ (ZAIPromptMsg *)showWithText:(NSString *)text duration:(CGFloat)duration inView:(UIView *)view orientationSensitive:(BOOL)orientationSensitive
{
    ZAIPromptMsg *toast = [ZAIPromptMsg sharedInstance];
    [toast setText:text];
    toast.orientationSensitive = orientationSensitive;
    [toast setDuration:duration];
    [toast showInView:view];
    return toast;
}

+ (ZAIPromptMsg *)showWithText:(NSString *)text topOffset:(CGFloat)topOffset duration:(CGFloat)duration
{
    ZAIPromptMsg *toast = [ZAIPromptMsg sharedInstance];
    [toast setText:text];
    [toast setDuration:duration];
    [toast showFromTopOffset:topOffset];
    return toast;
}

+ (ZAIPromptMsg *)showWithText:(NSString *)text bottomOffset:(CGFloat)bottomOffset duration:(CGFloat)duration
{
    ZAIPromptMsg *toast = [ZAIPromptMsg sharedInstance];
    [toast setText:text];
    [toast setDuration:duration];
    [toast showFromBottomOffset:bottomOffset];
    return toast;
}

+ (ZAIPromptMsg *)showWithText:(NSString *)text
{
    return [ZAIPromptMsg showWithText:text duration:Default_Display_Duration];
}

+ (ZAIPromptMsg *)showWithText:(NSString *)text topOffset:(CGFloat)topOffset
{
    return [ZAIPromptMsg showWithText:text topOffset:topOffset duration:Default_Display_Duration];
}

+ (ZAIPromptMsg *)showWithText:(NSString *)text bottomOffset:(CGFloat)bottomOffset
{
    return [ZAIPromptMsg showWithText:text bottomOffset:bottomOffset duration:Default_Display_Duration];
}

+ (ZAIPromptMsg *)showWithText:(NSString *)text inView:(UIView *)view orientationSensitive:(BOOL)orientationSensitive
{
    return [ZAIPromptMsg showWithText:text duration:Default_Display_Duration inView:view orientationSensitive:orientationSensitive];
}

#pragma mark
-(void)setText:(NSString *)text
{
    UIFont * font = nil;
    if (Default_Font_Size > self.promptFontSize)
    {
        font = [UIFont systemFontOfSize:self.promptFontSize];
    }
    else
    {
        font = [UIFont boldSystemFontOfSize:Default_Font_Size];
    }
    _msgLable.font = font;
    
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil].size;
    _contentView.frame = CGRectMake(0, 0, textSize.width, textSize.height);
    _contentView.layer.cornerRadius = self.promptRadius;
    _contentView.layer.masksToBounds = YES;
    _contentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:self.promptAlpha];
    _msgLable.frame = _contentView.frame;
    _msgLable.text = text;
}

- (void)setDuration:(CGFloat)duration
{
    if (duration <= 0.0f)
    {
        duration = NSIntegerMax;
    }
    _duration = duration;
}

-(void)showAnimation
{
    if (_contentView.alpha>0.7)
    {
        _contentView.alpha = 0.7f;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.alpha = 1.0f;
    }];
}

-(void)hideAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.alpha = 0.0f;
    }
    completion:^(BOOL finished)
    {
        [self dismissPrompt];
    }];
}

-(void)dismissPrompt
{
    [_contentView removeFromSuperview];
}

- (void)showToast
{
    _viewAutoresizingMask = UIViewAutoresizingNone;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self showInView:window withCenterPosition:[UIApplication sharedApplication].keyWindow.center ZoomMax:self.isZoomMax];
}

- (void)showInView:(UIView *)view withCenterPosition:(CGPoint)centerSize ZoomMax:(BOOL)isZoom
{
    CGSize textSize = _msgLable.frame.size;
    if (isZoom)
    {
        textSize.width += 30;
        textSize.height += 20;
        textSize.width = MAX(textSize.width, 150);
        textSize.height = MAX(textSize.height, 83);
    }
    else
    {
        textSize.width += 30;
        textSize.height += 20;
    }
    _contentView.frame = CGRectMake(0, 0, textSize.width, textSize.height);
    _msgLable.center = CGPointMake(textSize.width/2, textSize.height/2);
    
    _contentView.center = centerSize;
    
    if (_contentView.superview!=view)
    {
        [_contentView removeFromSuperview];
        [view addSubview:_contentView];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self showAnimation];
    
    if (_duration<0)
    {
        return;
    }
    if (_duration==0)
    {
        _duration = Default_Display_Duration;
    }
    
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:_duration];
}

- (void)showInView:(UIView *)view
{
    _viewAutoresizingMask = UIViewAutoresizingNone;
    [self showInView:view withCenterPosition:view.center ZoomMax:YES];
}

- (void)showFromTopOffset:(CGFloat)top
{
    _topMargin = top;
    _viewAutoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGPoint point = CGPointMake(window.center.x, top);
    [self showInView:window withCenterPosition:point ZoomMax:NO];
}

- (void)showFromBottomOffset:(CGFloat)bottom
{
    _bottomMargin = bottom;
    _viewAutoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGPoint point = CGPointMake(window.center.x, window.frame.size.height-_bottomMargin);
    [self showInView:window withCenterPosition:point ZoomMax:NO];
}

@end
