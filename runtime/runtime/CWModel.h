//
//  CWModel.h
//  runtime
//
//  Created by wangcyan on 16/11/28.
//  Copyright © 2016年 cyanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWModel : NSObject

/** 字典转模型 */
+ (instancetype)modelWithDict:(NSDictionary *)dict;
/** 打印 */
+ (NSString *)resolveDict:(NSDictionary *)dict;

@end
