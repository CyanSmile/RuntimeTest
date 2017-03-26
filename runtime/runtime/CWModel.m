//
// CWModel.m
// runtime
//
// Created by wangcyan on 16/11/28.
// Copyright © 2016年 cyanwang. All rights reserved.
//

#import "CWModel.h"
#import "objc/runtime.h"
#import <objc/message.h>

@implementation CWModel

/** 使用运行时遍历模型中所有属性，不明白的地方可以分布执行打印，便可明白 */
+ (instancetype)modelWithDict:(NSDictionary *)dict {

    //创建对象
    id objc = [[[self class] alloc] init];//或id objc = [[self alloc] init];
    
    //利用runtime给对象中的成员属性赋值
    /*
     * class_copyIvarList:获取类中的所有成员属性
     * Ivar:成员属性的意思
     * 两个参数的含义:第一个参数：表示获取哪个类中的成员属性，第二个参数：表示这个类有多少成员属性，传入一个Int变量地址，会自动给这个变量赋值
     * 返回值Ivar *：指的是一个ivar数组，会把所有成员属性放在一个数组中，通过返回的数组就能全部获取到。
     */
    
    unsigned int count;
    //获取类中的所有成员属性类型
    objc_property_t *propertys = class_copyPropertyList(self, &count);
    //获取类中的所有成员属性名
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    for (int i = 0; i < count; i++) {
        //根据角标，从数组取出对应的成员属性
        Ivar ivar = ivarList[i];
        
        //获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        //处理成员属性名->字典中的key，从第一个角标开始截取
        NSString *key = [name substringFromIndex:1];
        
        //根据成员属性名去字典中查找对应的value
        id value = dict[key];
        
        //二级转换:如果字典中还有字典，需要把对应的字典转换成模型
        //判断下value是否是字典
        if ([value isKindOfClass:[NSDictionary class]]) {
            //（1）.字典转模型
            //获取成员属性类型
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            //裁剪类型字符串
            NSRange range = [type rangeOfString:@"\""];
            type = [type substringFromIndex:range.location + range.length];
            range = [type rangeOfString:@"\""];
            type = [type substringToIndex:range.location];
            
            if ((![type isEqualToString:@"NSDictionary"]) && (![type isEqualToString:@"NSMutableDictionary"])){
                //根据字符串类名生成类对象
                Class modelClass = NSClassFromString(type);
                if (modelClass) { //有对应的模型才需要转
                    
                    //把字典转模型
                    value  =  [modelClass modelWithDict:value];
                }
            }
        }
        
        objc_property_t property = propertys[i];
        const char *attrs = property_getAttributes(property);
        NSString* propertyAttributes = @(attrs);
        
        //三级转换：NSArray中也是字典，把数组中的字典转换成模型.
        //判断值是否是数组
        if ([value isKindOfClass:[NSArray class]]) {
            //判断对应类有没有实现字典数组转模型数组的协议
            NSString *type = propertyAttributes;
            NSRange range = [type rangeOfString:@"\""];
            type = [type substringFromIndex:range.location + range.length];
            range = [type rangeOfString:@"\""];
            type = [type substringToIndex:range.location];
            if ((![type isEqualToString:@"NSArray"]) && (![type isEqualToString:@"NSMutableArray"])) {
                //生成模型
                NSRange range = [type rangeOfString:@"<"];
                type = [type substringFromIndex:range.location + range.length];
                range = [type rangeOfString:@">"];
                type = [type substringToIndex:range.location];
                Class classModel = NSClassFromString(type);
                NSMutableArray *arrM = [NSMutableArray array];
                //遍历字典数组，生成模型数组
                for (NSDictionary *dict in value) {
                    //字典转模型
                    id model =  [classModel modelWithDict:dict];
                    [arrM addObject:model];
                }
                //把模型数组赋值给value
                value = arrM;
            }
        }
        
        NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
        NSString *type = attributeItems[0];
        NSArray *typeArray = @[@"Tf",@"Ti", @"Td", @"Tl",@"Tc",@"Ts", @"Tq", @"TB"];
        if ([typeArray containsObject:type]) {
            //基本数据类型
            SEL setMethod = [self setObjcWith:key];
            //创建一个函数签名，这个签名可以是任意的，但需要注意，签名函数的参数数量要和调用的一致。
            NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:setMethod];
            //通过签名初始化
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
            //设置selector
            [invocation setSelector:setMethod];
            //注意：1、这里设置参数的Index 需要从2开始，因为前两个被selector和target占用。
            if ([type isEqualToString:@"Tf"]) {
                float fvalue = [value floatValue];
                [invocation setArgument:&fvalue atIndex:2];
            } else if ([type isEqualToString:@"Td"]) {
                double dvalue = [value doubleValue];
                [invocation setArgument:&dvalue atIndex:2];
            } else if ([type isEqualToString:@"Ti"]) {
                int ivalue = [value intValue];
                [invocation setArgument:&ivalue atIndex:2];
            } else if ([type isEqualToString:@"Tl"] || [type isEqualToString:@"Tq"]) {
                long lvalue = [value longValue];
                [invocation setArgument:&lvalue atIndex:2];
            } else if ([type isEqualToString:@"Tc"] || [type isEqualToString:@"TB"]) {
                BOOL bvalue = [value boolValue];
                [invocation setArgument:&bvalue atIndex:2];
            } else if ([type isEqualToString:@"Ts"]) {
                short svalue = [value shortValue];
                [invocation setArgument:&svalue atIndex:2];
            }
            
            [invocation invokeWithTarget:objc];
            
        } else if ([type isEqualToString:@"@?"]) {
#warning mark -- block类型
             /** 待做*/
        } else {
            if (value) { //有值，才需要给模型的属性赋值,利用KVC给模型中的属性赋值
                [objc setValue:value forKey:key];
            }
        }
   
    }
    
    return objc;
}

+ (SEL)setObjcWith:(NSString *)key {
    NSString *selName = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
    SEL setObjc = NSSelectorFromString(selName);
    return setObjc;
}

//自动打印属性字符串
+ (NSString *)resolveDict:(NSDictionary *)dict{
    
    //拼接属性字符串代码
    NSMutableString *strM = [NSMutableString string];
    
    //1.遍历字典，把字典中的所有key取出来，生成对应的属性代码
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        //类型经常变，抽出来
        NSString *type;
        
        if ([obj isKindOfClass:NSClassFromString(@"__NSCFString")]) {
            type = @"NSString";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFArray")]){
            type = @"NSArray";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")]){
            type = @"int";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFDictionary")]){
            type = @"NSDictionary";
        }
        
        //属性字符串
        NSString *str;
        if ([type containsString:@"NS"]) {
            str = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;",type,key];
        }else{
            str = [NSString stringWithFormat:@"@property (nonatomic, assign) %@ %@;",type,key];
        }
        
        //每生成属性字符串，就自动换行。
        [strM appendFormat:@"\n%@\n",str];
        
    }];
    
    //把拼接好的字符串打印出来，就好了。
    NSLog(@"%@",strM);
    return [NSString stringWithFormat:@"%@", strM];
    
}

@end
