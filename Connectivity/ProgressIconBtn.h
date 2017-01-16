//
//  ProgressIconBtn.h
//  Connectivity
//
//  Created by siping ruan on 17/1/13.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 带进度条的图像按钮
 */
@interface ProgressIconBtn : UIView

/**
 当前进度值
 */
@property (assign, nonatomic, readonly) CGFloat progressValue;
/**
 昵称Lable
 */
@property (weak, nonatomic, readonly) UILabel *nickName;
/**
 进度条宽度(默认3.0)
 */
@property (assign, nonatomic) CGFloat progressWidth;
/**
 进度条颜色(默认灰色)
 */
@property (strong, nonatomic) UIColor *progressColor;
/**
 绑定icon按钮的点击事件
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
/**
 设置进度值
 */
- (void)setProgressValue:(CGFloat)value;

@end
