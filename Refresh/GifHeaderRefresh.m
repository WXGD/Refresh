//
//  GifHeaderRefresh.m
//  Refresh
//
//  Created by apple on 2017/12/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "GifHeaderRefresh.h"

@interface GifHeaderRefresh ()

/** 普通状态图片 */
@property (strong, nonatomic) UIImageView *idleImg;
/** 普通状态图片 */
@property (strong, nonatomic) UIImage *idleIm;
/** 刷新状态状态图片 */
@property (strong, nonatomic) UIImageView *refreshImg;

@end

@implementation GifHeaderRefresh


#pragma mark - 懒加载
- (UIImageView *)refreshImg {
    if (!_refreshImg) {
        UIImageView *refreshImg = [[UIImageView alloc] init];
        [self addSubview:_refreshImg = refreshImg];
    }
    return _refreshImg;
}
- (UIImageView *)idleImg {
    if (!_idleImg) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:_idleImg = imageView];
    }
    return _idleImg;
}
#pragma mark - 重写父类的方法
- (void)prepare{
    [super prepare];
    // 隐藏时间
    self.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    self.stateLabel.hidden = YES;
    // 下拉试图高度
    self.mj_h = 70;
}

/** 布局子视图 */
- (void)placeSubviews {
    [super placeSubviews];
    if (self.refreshImg.constraints.count) return;
    // 刷新状态状态图片
    self.refreshImg.frame = self.bounds;
    self.refreshImg.contentMode = UIViewContentModeCenter;
    // 普通状态状态图片
    self.idleImg.x = 0;
    self.idleImg.width = self.width;
    self.idleImg.contentMode = UIViewContentModeCenter;
}



/** 拉拽的百分比 */
- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    // 视图正在下拉
    if (0 < pullingPercent && pullingPercent <= 1) {
        // 普通状态图片高度
        self.idleImg.height = self.height - 70.0 * (1 - pullingPercent);
        // 普通状态图片y值
        self.idleImg.y = 70.0 * (1-pullingPercent);
        // 普通状态图片
        self.idleIm = [UIImage imageNamed:@"header"];
        self.idleIm = [self scaleToSize:self.idleIm size:CGSizeMake(self.idleIm.size.width * pullingPercent, self.idleIm.size.height * pullingPercent)];
        self.idleImg.image = self.idleIm;
    }
}
/** 下拉状态 */
- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    switch (state) {
        case MJRefreshStateIdle: { // 普通闲置状态
            // 停止刷新动画
            [self.refreshImg stopAnimating];
            // 隐藏刷新状态图片
            [self.refreshImg setHidden:YES];
            // 展示普通状态图片
            [self.idleImg setHidden:NO];
            break;
        }
        case MJRefreshStateRefreshing: { // 正在刷新中的状态
            // 隐藏普通状态图片
            [self.idleImg setHidden:YES];
            // 展示刷新状态图片
            [self.refreshImg setHidden:NO];
            // 刷新状态图片
            self.refreshImg.animationImages = @[[UIImage imageNamed:@"gif_header_1"], [UIImage imageNamed:@"gif_header_2"], [UIImage imageNamed:@"gif_header_3"], [UIImage imageNamed:@"gif_header_4"]];
            self.refreshImg.animationDuration = 0.4;
            // 开始刷新动画
            [self.refreshImg startAnimating];
            break;
        }
        default:
            break;
    }
}



#pragma makr - 封装方法
// 图片缩放到指定大小尺寸
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end

