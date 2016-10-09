//
//  CKBannerView.m
//  CKBannerViewDemo
//
//  Created by hc_cyril on 2016/9/23.
//  Copyright © 2016年 Clark. All rights reserved.
//

#import "CKBannerView.h"
#import "UIImageView+WebCache.h"

#define kWidth CGRectGetWidth(self.frame)
#define KHeight CGRectGetHeight(self.frame)
static CGFloat kPageControlHeight = 20;

@interface CKBannerViewCell:UICollectionViewCell
@property (nonatomic, copy) id itemData;
+ (instancetype)collectionView:(UICollectionView *)tableView indexPatch:(NSIndexPath *)indexPath;
@end


@interface CKBannerView ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) CGFloat selfWidth;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat collectionViewWidth;
@property (nonatomic, assign) CGFloat oldOffset;
@end


@implementation CKBannerView
@synthesize autoScroll = _autoScroll;
@synthesize scrollInterval = _scrollInterval;

#pragma mark - life cycle 
- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        [self setUpSubviews];
        
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if (self = [super initWithCoder:aDecoder]) {
        [self setUpSubviews];
    }
    return self;
}

#pragma mark - primate methods

- (void)setUpSubviews {
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
}
- (void)reloadData
{
    if (!self.dataSource || self.itemCount == 0) {
        return;
    }
    self.pageControl.numberOfPages = self.itemCount;
    
    [self.collectionView reloadData];
    
}
//计时器
- (void)startTimer {
    [self stopTimer];
    if (self.itemCount == 0 || self.itemCount == 1 || !self.autoScroll)
    {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
//自动滑动
- (void)scrollToNextPage {
    
    CGFloat newOffSetLength = self.offset + self.selfWidth;
    //在换页到最后一个的时候多加一点距离，触发回到第一个图片的事件
    if (newOffSetLength == self.collectionViewWidth - self.selfWidth) {
        newOffSetLength += 1;
    }
    CGPoint offSet;
    offSet = CGPointMake(newOffSetLength, 0);

    [self.collectionView setContentOffset:offSet  animated:YES];
    //修复在滚动动画进行中切换tabbar或push一个新的controller时导致图片显示错位问题。
    //原因：系统会在view not-on-screen时移除所有coreAnimation动画，导致动画无法完成，轮播图停留在切换中间的状态。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //动画完成后的实际offset和应该到达的offset不一致，重置offset。
        if (self.offset!=newOffSetLength && self.offset!=0) {
            self.collectionView.contentOffset = offSet;
        }
    });
}

- (void)stopTimer {

    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - --UICollectionViewDelegate and UICollectionViewDataSource--
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.itemCount == 1) {
        return 1;
    }
    return  self.itemCount + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    CKBannerViewCell *cell  = [CKBannerViewCell collectionView:collectionView indexPatch:indexPath];
    if ([self.dataSource respondsToSelector:@selector(bannerView:itemDataAtIndex:)]) {
        NSInteger indexPathItem = indexPath.item;
        if (indexPathItem == self.itemCount){
            indexPathItem = 0;
        }
        cell.itemData = [self.dataSource bannerView:self itemDataAtIndex:indexPathItem];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    

    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectedItemAtIndex:)]) {
        [self.delegate bannerView:self didSelectedItemAtIndex:self.pageControl.currentPage];
    }
}

#pragma mark - UIScrollViewDelegate 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 用户滑动时停止定时器
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"collectionView.contentOffset.x == %lu",(long)self.collectionView.contentOffset.x);
    self.pageControl.currentPage = self.offset / self.selfWidth;
    [self startTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    if (self.oldOffset > self.offset) {
        if (self.offset < 0)
        {
            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.itemCount inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }else{
        if (self.offset > self.collectionViewWidth - self.selfWidth) {
            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
    self.pageControl.currentPage = self.offset / self.selfWidth;
    self.oldOffset = self.offset;
}

#pragma mark - --setter and getter methods--
- (UICollectionView *)collectionView {

    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kWidth, KHeight) collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.bouncesZoom = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[CKBannerViewCell class] forCellWithReuseIdentifier:@"CKBannerViewCell"];
    }
    return _collectionView;
}
- (UIPageControl *)pageControl {

    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, KHeight - kPageControlHeight, kWidth, kPageControlHeight)];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
        
    }
    return _pageControl;
}
- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.sectionInset = UIEdgeInsetsZero;
        _flowLayout.itemSize = CGSizeMake(kWidth, KHeight);
    }
    return _flowLayout;
}

/**
 *  数据源
 */
- (void)setDataSource:(id<CKBannerViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    // 刷新数据
    [self reloadData];
    
    self.autoScroll = YES;
}

- (NSInteger)itemCount {

    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInBannerView:)]) {
        return [self.dataSource numberOfItemsInBannerView:self];
    }
    return 0;
}

/**
 *  是否自动滑动
 */
- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    
    if (autoScroll) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}


- (BOOL)autoScroll
{
    if (self.itemCount < 2) {
        // itemCount小于2时, 禁用自动滑动
        return NO;
    }
    return _autoScroll;
}

/**
 *  自动滑动间隔时间
 */
- (void)setScrollInterval:(CGFloat)scrollInterval
{
    _scrollInterval = scrollInterval;
    
    [self startTimer];
}

- (CGFloat)scrollInterval
{
    if (!_scrollInterval) {
        _scrollInterval = 3.0; // default
    }
    return _scrollInterval;
}

- (CGFloat)selfWidth {
    return CGRectGetWidth(self.frame) ;
}

- (CGFloat)offset {
    return  self.collectionView.contentOffset.x ;
}

- (CGFloat)collectionViewWidth {
    return self.collectionView.contentSize.width;
}


@end

#pragma mark - --------CKBannerViewCell---------
@interface CKBannerViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation CKBannerViewCell

+ (instancetype)collectionView:(UICollectionView *)collectionView indexPatch:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"CKBannerViewCell";
    CKBannerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setItemData:(id)itemData {

    if ([itemData isKindOfClass:[NSString class]]) {
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:(NSString *)itemData] placeholderImage:nil];
        
    } else if ([itemData isKindOfClass:[NSURL class]]) {
        
        [self.imageView sd_setImageWithURL:(NSURL *)itemData placeholderImage:nil];
        
    } else if ([itemData isKindOfClass:[UIImage class]]) {
    
        self.imageView.image = (UIImage *)itemData;
    } else if ([itemData isKindOfClass:[NSData class]]) {
        
        UIImage *image = [UIImage imageWithData:(NSData *)itemData];
        self.imageView.image = image;
    }
}

#pragma mark - setter and getter methods

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
    return _imageView;
}


@end

