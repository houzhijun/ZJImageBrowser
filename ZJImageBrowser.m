//
//  ZJImageBrowser.m
//  RGMall
//
//  Created by RG on 2018/9/19.
//  Copyright © 2018年 RongGeJinRong. All rights reserved.
//

#import "ZJImageBrowser.h"

#define Scr_W [UIScreen mainScreen].bounds.size.width

#define Scr_H [UIScreen mainScreen].bounds.size.height

#define Main_center_x Scr_W/2.0f

#define Main_center_y Scr_H/2.0f

#define Factor(float)  (Scr_H - float)/Scr_H

#define ScaleMAX 5.0f


@interface ZJImageBrowser()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation ZJImageBrowser
{
    UIView * _alpahView;
    CGFloat _totalScale;
    //相对于原点的偏移量
    CGSize _moveTotalSize;
    CGRect _moveBeforeRect;
    //透明度
    CGFloat _alpah;
    /**防止多次调用查看器*/
    NSLock  * _browserLock;
    //取消参看
    BOOL _isCancel;
    NSInteger _curIndex;
    NSInteger _beforIndex;
    
}

static  ZJImageBrowser  * _shareBrowser = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _browserLock = [[NSLock alloc] init];
    }
    return self;
}

+(ZJImageBrowser *)shareBrowser{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_shareBrowser) {
            _shareBrowser = [self new];
        }
    });
    return _shareBrowser;
}

/**多张图片 */
- (void)scanImageWithImagePaths:(NSArray<NSString *> *)imagePaths currentImageIndex:(NSInteger)index alpah:(CGFloat)alpah{
    
    //上锁
    [_browserLock lock];
    _isCancel = NO;
    _curIndex = index;
    
    _alpah = alpah < 0.0 ? 1.0f : alpah;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    _alpahView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Scr_W, Scr_H)];
    [_alpahView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:0/255.0 blue:0/255.0f alpha:_alpah]];
    [window addSubview:_alpahView];
    
    UIScrollView * scrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Scr_W, Scr_H)];
    scrView.delegate = self;
    scrView.contentSize = CGSizeMake(Scr_W * [imagePaths count], 0);
    scrView.pagingEnabled = YES;
    
    for (NSInteger i = 0; i<[imagePaths count]; i++) {
        
        UIView * backgroundView = [[UIView alloc] initWithFrame:CGRectMake(Scr_W*i, 0, Scr_W, Scr_H)];
        backgroundView.tag = 100+i;
        backgroundView.alpha = 0;
        CGRect defultRect = CGRectMake(0,  Main_center_y-100, Scr_W, 200);
        //创建imgView
        UIImageView * imgView = [[UIImageView alloc] initWithFrame:defultRect];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.tag = 1000+i;
        [imgView sd_setImageWithURL:[NSURL URLWithString:imagePaths[i]] placeholderImage:[UIImage imageNamed:@"goods_icon.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                return ;
            }
            
            [UIView animateWithDuration:0.25 animations:^{
                CGFloat y,width, height;
                width = Scr_W;
                height = image.size.height *  (Scr_W/image.size.width);
                y = ( Scr_H - height)*0.5f;
                imgView.frame = CGRectMake(0,y, width, height);
                [backgroundView setAlpha:1.0f];
                
            }];
            
        }];
        [backgroundView addSubview:imgView];
        [scrView addSubview:backgroundView];
        
        //添加多个手势
        [self addMultiGestureInView:backgroundView];
    }
    
    scrView.contentOffset = CGPointMake(Scr_W* index, 0);
    [window addSubview:scrView];
    [scrView setAlpha:1.0f];
    
}

/**查看单张图片*/
- (void)scanImageWithImagePath:(NSString *)imagePath alpah:(CGFloat)alpah{
    
    //上锁
    [_browserLock lock];
    _isCancel = NO;
    _curIndex = 0;
    
    _alpah = alpah < 0.0 ? 1.0f : alpah;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    _alpahView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Scr_W, Scr_H)];
    [_alpahView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:0/255.0 blue:0/255.0f alpha:_alpah]];
    [window addSubview:_alpahView];
    UIView * backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Scr_W, Scr_H)];
    [backgroundView setAlpha:0];
    
    //创建imgView
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,  Main_center_y-100, Scr_W, 200)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.tag = 1000;
    [backgroundView addSubview:imgView];
    [window addSubview:backgroundView];
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"goods_icon.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            return ;
        }
        [UIView animateWithDuration:0.25 animations:^{
            CGFloat y,width, height;
            width = Scr_W;
            height = image.size.height *  (Scr_W/image.size.width);
            y =( Scr_H - height)*0.5f;
            imgView.frame = CGRectMake(0,y, width, height);
            [backgroundView setAlpha:1.0f];
        }];
    }];
    
    //添加多个手势
    [self addMultiGestureInView:backgroundView];
}

/*
 *  单个图片
 */
- (void)scanShowImage:(UIImage *)image alpah:(CGFloat)alpah{
    
    //上锁
    [_browserLock lock];
    _isCancel = NO;
    _curIndex = 0;
    
    _alpah = alpah < 0.0 ? 1.0f : alpah;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    _alpahView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Scr_W, Scr_H)];
    [_alpahView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:0/255.0 blue:0/255.0f alpha:_alpah]];
    [window addSubview:_alpahView];
    UIView * backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Scr_W, Scr_H)];
    [backgroundView setAlpha:0];
    
    CGRect defultRect = CGRectMake(0,  Main_center_y-100, Scr_W, 200);
    //创建imgView
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:defultRect];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = image;
    imgView.tag = 1000;
    [backgroundView addSubview:imgView];
    [window addSubview:backgroundView];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat y,width, height;
        width = Scr_W;
        height = imgView.image.size.height *  (Scr_W/imgView.image.size.width);
        y =( Scr_H - height)*0.5f;
        imgView.frame = CGRectMake(0,y, width, height);
        [backgroundView setAlpha:1.0f];
    }];
    
    //添加多个手势
    [self addMultiGestureInView:backgroundView];
}

/** 同时添加多种手势 */
- (void)addMultiGestureInView:(UIView *)inView{
    //点击手势
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitImageEditer:)];
    singleTap.numberOfTapsRequired = 1;
    [inView addGestureRecognizer:singleTap];
    
    //双击更大手势
    UITapGestureRecognizer * moreTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    moreTap.numberOfTapsRequired = 2;
    [inView addGestureRecognizer:moreTap];
    [singleTap requireGestureRecognizerToFail:moreTap];
    
    //捏合手势
    UIPinchGestureRecognizer * pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    _totalScale = 1.0f;
    [inView addGestureRecognizer:pinchGesture];
    
    //摇动或者拖动
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawImageGusture:)];
    panGesture.delegate = self;
    [inView addGestureRecognizer:panGesture];
}

/**退出查看器*/
- (void)exitImageEditer:(UIGestureRecognizer *)gesture{
    
    UIView * backgroundView = gesture.view;
    UIImageView * imgView = [gesture.view viewWithTag:1000+_curIndex];
    if ([backgroundView.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView * scrView = (UIScrollView*)backgroundView.superview;
        [UIView animateWithDuration:0.5 animations:^{
            imgView.transform = CGAffineTransformScale(imgView.transform, 0.6, 0.6);
            imgView.alpha = 0.5;
            _alpahView.alpha = 0.2;
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
            [scrView removeFromSuperview];
            [_alpahView removeFromSuperview];
            
        }];
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            imgView.transform = CGAffineTransformScale(imgView.transform, 0.6, 0.6);
            imgView.alpha = 0.5;
            _alpahView.alpha = 0.2;
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
            [_alpahView removeFromSuperview];
        }];
    }
    
    //解锁
    [_browserLock unlock];
}

/**将图片放大，当图片为最大化时恢复原来大小*/
- (void)doubleTap:(UITapGestureRecognizer *)gesture{
    
    UIView * backView = (UIView *)gesture.view;
    UIImageView * imgView = [backView viewWithTag:1000+_curIndex];
    if (CGRectGetWidth(imgView.frame) != Scr_W) {
        CGFloat y,width, height;
        width = Scr_W;
        height = imgView.image.size.height *  (Scr_W/imgView.image.size.width);
        y =( Scr_H - height)*0.5f;
        [UIView animateWithDuration:0.25 animations:^{
            imgView.frame = CGRectMake(0,y, width, height);
        }];
        
    }else{
        
        [UIView animateWithDuration:0.25 animations:^{
            imgView.transform = CGAffineTransformScale(imgView.transform, 2, 2);
        }];
    }
    
}

/**捏合图片*/
- (void)scaleImage:(UIPinchGestureRecognizer *)gesture{
    
    UIView * backView = (UIView *)gesture.view;
    UIImageView * imgView = [backView viewWithTag:1000+_curIndex];
    CGFloat scale = gesture.scale;
    _totalScale *= gesture.scale;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        imgView.transform = CGAffineTransformScale(imgView.transform, scale, scale);
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        //如果小于屏幕宽度
        if (CGRectGetWidth(imgView.frame) < Scr_W) {
            CGFloat y,width, height;
            width = Scr_W;
            height = imgView.image.size.height *  (Scr_W/imgView.image.size.width);
            y =( Scr_H - height)*0.5f;
            [UIView animateWithDuration:0.25 animations:^{
                imgView.frame = CGRectMake(0,y, width, height);
            }];
        }
    }
    
    //将缩放比例置零
    gesture.scale = 1.0f;
}

/**拖拽*/
- (void)drawImageGusture:(UIPanGestureRecognizer *)gesture{
    
    UIView * backView = (UIView *)gesture.view;
    UIImageView * imgView = [backView viewWithTag:1000+_curIndex];
    CGSize imgViewSize = imgView.frame.size;
    CGPoint imgViewOrigin = imgView.frame.origin;
    CGPoint center = imgView.center;
    
    /*
     拖拽的一秒内偏移量(该值与拖拽对象大小、拖拽速度成正比)
     points/second in the coordinate system of the specified view
     */
    CGPoint velocityPoint = [gesture velocityInView:gesture.view];
    
    //单次偏移的坐标点
    CGPoint translationPoint = [gesture translationInView:gesture.view];
    center.x += translationPoint.x;
    center.y += translationPoint.y;
    imgView.center = center;
    _moveTotalSize = CGSizeMake(_moveTotalSize.width+ translationPoint.x, _moveTotalSize.height + translationPoint.y);
    
    //计算透明度及缩放因子
    CGFloat factor = Factor(_moveTotalSize.height);
    
    //是否取消查看
    if (velocityPoint.y > 999 || factor <= 0.5) {
        _isCancel = YES;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        _moveBeforeRect = imgView.frame;
        _moveTotalSize = CGSizeMake(translationPoint.x, translationPoint.y);
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        
        CGFloat alpah = _alpah * factor;//
        if (alpah < 0.1) {
            alpah = 0.1;
        }
        if (alpah >1.0f) {
            alpah = 1.0f;
        }
        _alpahView.alpha = alpah;
        
        //设置向下拖拽时缩小图片
        if (_moveTotalSize.height > 0 && _moveBeforeRect.origin.y > 0 && fabs(_moveTotalSize.height) >fabs(_moveTotalSize.width)) {
            CGRect kRect = imgView.frame;
            kRect.size = CGSizeMake(CGRectGetWidth(_moveBeforeRect)*factor, CGRectGetHeight(_moveBeforeRect)*factor);
            imgView.frame = kRect;
            imgView.center = center;
        }
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        if (_isCancel == YES ) {
            [self exitImageEditer:gesture];
            return;
        }
        
        //设置原点极值
        //X:
        CGFloat minX = imgViewSize.width > Scr_W ? Scr_W-imgViewSize.width : 0 ;
        CGFloat maxX = imgViewSize.width > Scr_W ? 0 : Scr_W-imgViewSize.width;
        //Y:
        CGFloat minY = imgViewSize.height >Scr_H ?  Scr_H- imgViewSize.height : 0;
        CGFloat maxY = imgViewSize.height >Scr_H ? 0 : Scr_H- imgViewSize.height;
        
        //设置拖拽后的原点坐标(finalX,finalY);
        CGFloat finalX,finalY;
        if (imgViewOrigin.x >= minX && imgViewOrigin.x <= maxX) {
            finalX = imgViewOrigin.x + translationPoint.x;
        }else if (imgViewOrigin.x < minX){
            finalX = minX;
        }else {
            finalX = maxX;
        }
        
        if (imgViewOrigin.y >= minY && imgViewOrigin.y <= maxY) {
            finalY = imgViewOrigin.y + translationPoint.y;
        }else if (imgViewOrigin.y < minY){
            finalY = minY;
        }else {
            finalY = maxY;
        }
        
        if (imgViewSize.height <= Scr_H) {
            finalY = (Scr_H - imgViewSize.height)/2;
        }
        
        //设置最终坐标
        [UIView animateWithDuration:0.25 animations:^{
            _alpah = 1.0f;
            _alpahView.alpha = _alpah;
            
            //判断是否有缩小图片，如果缩小就复原
            if (imgViewSize.width != CGRectGetWidth(_moveBeforeRect) || imgViewSize.height != CGRectGetHeight(_moveBeforeRect)){
                imgView.frame = _moveBeforeRect;
                
            }else{
                imgView.frame = CGRectMake(finalX, finalY, imgViewSize.width, imgViewSize.height);
            }
            
        }];
        
        //将总偏移量置零
        _moveTotalSize = CGSizeZero;
    }
    
    //将单次偏移点置零
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
}

#pragma mark ==UIGestureRecognizerDelegate==
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![[gestureRecognizer.view superview] isKindOfClass:[UIWindow class]]) {
        UIPanGestureRecognizer * gusture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [gusture translationInView:gestureRecognizer.view];
        
        if (fabs(translation.y) < fabs(translation.x)) {

            return NO;
        }
    }
    
    return YES;
}

/**是否允许同时触发*/
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }

    return NO;
}

#pragma mark ==UIScrollViewDelegate==
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    _beforIndex = point.x/Scr_W;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint point = scrollView.contentOffset;
    _curIndex = point.x/Scr_W;
    scrollView.contentOffset = CGPointMake(_curIndex*Scr_W, 0);
    
    if (_curIndex != _beforIndex) {
        UIView * bgView = [scrollView viewWithTag:100+_beforIndex];
        UIImageView * imgView = [bgView viewWithTag:1000+_beforIndex];
        if (CGRectGetWidth(imgView.frame) != Scr_W) {
            CGFloat y,width, height;
            width = Scr_W;
            height = imgView.image.size.height *  (Scr_W/imgView.image.size.width);
            y =( Scr_H - height)*0.5f;
            [UIView animateWithDuration:0.25 animations:^{
                imgView.frame = CGRectMake(0,y, width, height);
            }];
        }
    }
}


@end
