//
//  CWModel.h
//  runtime
//
//  Created by wangcyan on 16/11/28.
//  Copyright © 2016年 cyanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWModel : NSObject

+ (instancetype)modelWithDict:(NSDictionary *)dict;
+ (NSString *)resolveDict:(NSDictionary *)dict;

@end
