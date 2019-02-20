//
//  UpLoadUserpicTool.h

//  Created by chen on 19/1/26.
//  Copyright © 2019年 chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UploadModel.h"
typedef void(^FinishSelectImageBlcok)(UploadModel *model);
typedef void(^FinishSelectImageArrayBlcok)(NSMutableArray *imageArray);
@interface UpLoadUserpicTool : NSObject

+ (UpLoadUserpicTool *)shareManager;

- (void)selectUserpicSourceWithType:(NSString *)type WithViewController:(UIViewController *)viewController FinishSelectImageBlcok:(FinishSelectImageBlcok)finishSelectImageBlock;

@end
