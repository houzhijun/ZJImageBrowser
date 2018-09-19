//
//  ZJImageBrowser.h
//  RGMall
//
//  Created by RG on 2018/9/19.
//  Copyright © 2018年 RongGeJinRong. All rights reserved.
//

#import <Foundation/Foundation.h>
#warning  Need use SDWebImage
//#import "UIImageView+WebCache.h"

@interface ZJImageBrowser : NSObject

/**图片查看器*/
+ (ZJImageBrowser * )shareBrowser;

/*@description 查看单个图片
 *
 *@parameter  showImage:要查看的图片
 */
- (void)scanShowImage:(UIImage *)image alpah:(CGFloat)alpah;


/*@description 查看单张图片
 *
 *@parameter  showImage:要查看的图片路径
 */
- (void)scanImageWithImagePath:(NSString *)imagePath alpah:(CGFloat)alpah;


/*@description 查看多张图片
 *
 *@parameter  showImage:多张图片路径
 */
- (void)scanImageWithImagePaths:(NSArray<NSString *> *)imagePaths currentImageIndex:(NSInteger)index alpah:(CGFloat)alpah;


@end
