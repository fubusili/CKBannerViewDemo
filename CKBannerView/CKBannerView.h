//
//  CKBannerView.h
//  CKBannerViewDemo
//
//  Created by hc_cyril on 2016/9/23.
//  Copyright © 2016年 Clark. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CKBannerViewDataSource, CKBannerViewDelegate;


@interface CKBannerView : UIView
/** 是否自动滑动, 默认 YES */
@property (nonatomic, assign) BOOL autoScroll;
/** 自动滑动间隔时间(s), 默认 3s */
@property (nonatomic, assign) CGFloat scrollInterval;

@property (nonatomic, assign) id <CKBannerViewDelegate> delegate;
@property (nonatomic, assign) id<CKBannerViewDataSource> dataSource;

@end

@protocol CKBannerViewDataSource <NSObject>

@required

- (NSInteger)numberOfItemsInBannerView:(CKBannerView *)bannerView ;
- (id)bannerView:(CKBannerView *)bannerView itemDataAtIndex:(NSInteger)index;

@end

@protocol CKBannerViewDelegate <NSObject>
@optional
- (void)bannerView:(CKBannerView *)bannerView didSelectedItemAtIndex:(NSInteger)index;
@end
