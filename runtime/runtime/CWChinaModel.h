//
//  CWChinaModel.h
//  runtime
//
//  Created by wangcyan on 16/11/28.
//  Copyright © 2016年 cyanwang. All rights reserved.
//

#import "CWModel.h"
/*
 *"code": "110000",
 *"name": {"code": "110101", "name": "东城区"},
 *"cell": []
 */

/*
 *"code": "110100",
 *"name": "市辖区",
 *"cell": [{
 *"code": "110101",
 *"name": "东城区"
 *}]
 */

@interface CWAreaModel : CWModel

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;

@end

@protocol CWAreaModel @end

@interface CWCityModel : CWModel

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray <CWAreaModel>*cell;

@end

@protocol CWCityModel @end

@interface CWChinaModel : CWModel

@property (nonatomic, assign) BOOL ok;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) CWAreaModel *name;
@property (nonatomic, strong) NSArray <CWCityModel>*cell;
@property (nonatomic, strong) NSDictionary *nameDict;

@end
