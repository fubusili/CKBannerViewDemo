//
//  ViewController.m
//  CKBannerViewDemo
//
//  Created by hc_cyril on 2016/9/23.
//  Copyright © 2016年 Clark. All rights reserved.
//

#import "ViewController.h"
#import "CKBannerView.h"

@interface ViewController ()<CKBannerViewDataSource, CKBannerViewDelegate>
@property (nonatomic, strong) CKBannerView *bannerView;
@property (nonatomic, strong) NSMutableArray *dataSources;
@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 1; i < 5; i ++) {
        NSString *str = @"banner";
        str = [str stringByAppendingString:@(i).stringValue];
        [images addObject:[UIImage imageNamed:str]];
    }
    [self.dataSources addObjectsFromArray:images];
    [self.view addSubview:self.bannerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CKBannerViewDelegate 
- (NSInteger)numberOfItemsInBannerView:(CKBannerView *)bannerView {

    return self.dataSources.count;
}
- (id)bannerView:(CKBannerView *)bannerView itemDataAtIndex:(NSInteger)index{

    return [self.dataSources objectAtIndex:index];
}
- (void)bannerView:(CKBannerView *)bannerView didSelectedItemAtIndex:(NSInteger)index {

    NSLog(@"banner click %ld",(long)index);
}

#pragma mark - setter and getter methods
- (CKBannerView *)bannerView {

    if (!_bannerView) {
        _bannerView = [[CKBannerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds)*3/4)];
        _bannerView.dataSource = self;
        _bannerView.delegate = self;
        _bannerView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    return _bannerView;
}
- (NSMutableArray *)dataSources {

    if (!_dataSources) {
        _dataSources = [[NSMutableArray alloc] init];
    }
    return _dataSources;
}
@end
