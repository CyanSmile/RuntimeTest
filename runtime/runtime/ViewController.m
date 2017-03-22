//
//  ViewController.m
//  runtime
//
//  Created by wangcyan on 16/11/28.
//  Copyright © 2016年 cyanwang. All rights reserved.
//

#import "ViewController.h"
#import "CWChinaModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"china" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    
    NSMutableArray *data = [NSMutableArray array];
    
    data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    for (NSInteger index = 0; index < data.count; index++) {
        NSDictionary *dict = data[index];
        CWChinaModel *model = [CWChinaModel modelWithDict:dict];
        [data replaceObjectAtIndex:index withObject:model];
    }
    NSLog(@"%@", data);
    CWChinaModel *model = data[0];
    NSLog(@"%ld", model.number);
    CWCityModel *city = model.cell[0];
    NSLog(@"%@", city.cell);
    CWAreaModel *area = city.cell[0];
    NSLog(@"%@", area.name);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
