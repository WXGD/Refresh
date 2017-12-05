相较于弹出加载框式的加载方式，下拉刷新式加载方式所带来的用户体验要好很多，当前主流APP的下拉刷新动画也是越来越绚丽，最近因为项目需要，模仿美团外卖的下拉刷新，对项目中的下拉刷新进行了修改。（其实是万恶的设计师，非要模仿人家的设计，做为程序员只好费尽脑细胞了。）

 ![refresh.gif](http://upload-images.jianshu.io/upload_images/2262405-c3e985d0b2972f47.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

因为在项目中使用MJRefresh做为下拉刷新框架，因此所有的设计都是基于MJRefresh进行的修改。而MJRefresh也算是当前iOS开发使用的比较多的下拉刷新框架。

## 一、普通动态效果
首先加载动态图片在MJRefresh提供是提供的有现成的方法的，在MJRefreshGifHeader中，提供的就是加载动态图片的方法，使用起来也比较简单。
我一般的做法是继承MJRefreshGifHeader，重新创建一个类，用来设置动态图片加载的一些基本属性。

1、 重写下拉刷新的父类的方法

```
- (void)prepare{
[super prepare];
}
```

2、 更换动画图片

```
// 设置即将刷新状态的动画图片（一松开就会刷新的状态）
NSMutableArray *refreshingImages = [NSMutableArray array];
for (int i = 1; i<=22; i++) {
UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"gif_header_%d", i]];
[refreshingImages addObject:image];
}
// 设置正在刷新状态的动画图片
[self setImages:refreshingImages forState:MJRefreshStateRefreshing];
```

3、设计一些基本属性

```
// 隐藏时间
self.lastUpdatedTimeLabel.hidden = YES;
// 隐藏状态
self.stateLabel.hidden = YES;
// 下拉试图高度
self.mj_h = 70;
```

## 二、模仿美团外卖效果
如果只是实现加载动画，那么上面的做法其实已经能够实现了，可是如何才能实现上面那种随着下拉距离，图片不断放大的效果呢！
仔细分析MJRefreshGifHeader里面的效果不难发现，如果是继承于MJRefreshGifHeader是无法做到这样的效果的，那么很自然的就能想到，从MJRefreshGifHeader的父级来看看能否实现。
MJRefreshGifHeader的父级是MJRefreshStateHeader。
MJRefreshStateHeader里面的方法其实同MJRefreshGifHeader比较相似，比较重要的几个方法分别是：

```
// 初始化方法
- (void)prepare{
[super prepare];
}
// 布局子视图
- (void)placeSubviews {

}
// 拉拽的百分比
- (void)setPullingPercent:(CGFloat)pullingPercent {
[super setPullingPercent:pullingPercent];
}
// 下拉状态
- (void)setState:(MJRefreshState)state {
MJRefreshCheckState
}
```

搞清楚了这几个方法，接下来就比较简单了

1、在初始方法中，设置下拉刷新的基础属性

```
// 初始化方法
- (void)prepare{
[super prepare];
// 隐藏时间
self.lastUpdatedTimeLabel.hidden = YES;
// 隐藏状态
self.stateLabel.hidden = YES;
// 下拉试图高度
self.mj_h = 70;
}
```

2、在布局方法中创建imageView，用来展示动态图片

```
// 布局子视图
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
```
这里我分别创建了两个imageView，分别用在下拉阶段的放大缩小和加载阶段的动画展示，这主要是因为在开发过程中，我发现如果使用一个imageView，就会造成在加载阶段的动画图片尺寸变大的现象，具体是因为什么我也没有找到原因。

3、在拖拽方法中，对普通状态的图片信息缩放

```
// 拉拽的百分比
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
```
在初始化方法中曾经设置过一个属性
```
// 下拉试图高度
self.mj_h = 70;
```
这个属性的意思就是当下拉高度在0~70之间，拉拽的百分比属性pullingPercent，就在0~1之间。也就是说我们在pullingPercent为0~1的时候，对图片进行缩放。为了保证无论下拉高度在什么位置，图片都处在下拉区域的正中心，所有需要不停的改变图片的位置

```
// 普通状态图片高度
self.idleImg.height = self.height - 70.0 * (1 - pullingPercent);
// 普通状态图片y值
self.idleImg.y = 70.0 * (1-pullingPercent);
```
图片尺寸的修改方法，我进行了一个封装，

```
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
```

4、最后一步，就是在不同的刷新状态进行判断，然后对所需要展示的imageView进行切换。

```
// 下拉状态
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
```
这里我只判断了两个状态，在MJRefresh中总共为我们5个不同的状态

```
/** 普通闲置状态 */
MJRefreshStateIdle = 1,
/** 松开就可以进行刷新的状态 */
MJRefreshStatePulling,
/** 正在刷新中的状态 */
MJRefreshStateRefreshing,
/** 即将刷新的状态 */
MJRefreshStateWillRefresh,
/** 所有数据加载完毕，没有更多的数据了 */
MJRefreshStateNoMoreData
```

好了，到这里基本上就能实现上面图片的功能了，不过有一个问题，我一直没有解决，在进行图片大小缩放的时候，图片会出现模糊的情况，如果各位有人有解决方案的话，在此先谢谢了。


