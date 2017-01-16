//
//  ProgressIconBtn.m
//  Connectivity
//
//  Created by siping ruan on 17/1/13.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "ProgressIconBtn.h"

@interface ProgressIconBtn ()

@property (weak, nonatomic) UIButton *icon;
@property (weak, nonatomic) CAShapeLayer *shapeLayer;

@end

@implementation ProgressIconBtn

#pragma mark - Initial

- (instancetype)init
{
    if (self = [super init]) {
        [self addOwnViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addOwnViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configOwnViews];
}

- (void)drawRect:(CGRect)rect
{
    //shapeLayer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 3.0;
    CGFloat shapeWH = self.icon.frame.size.width + shapeLayer.lineWidth * 2.0;
    CGFloat shapeX = (rect.size.width - shapeWH) * 0.5;
    CGFloat shapeY = (rect.size.height - shapeWH) * 0.5;
    shapeLayer.frame = CGRectMake(shapeX, shapeY, shapeWH, shapeWH);
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor grayColor].CGColor;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 0.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:shapeLayer.bounds];
    shapeLayer.path = path.CGPath;
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
}

#pragma mark - Private

- (void)addOwnViews
{
    //icon
    UIButton *icon = [UIButton buttonWithType:UIButtonTypeCustom];
    icon.clipsToBounds = YES;
    [icon setBackgroundImage:[UIImage imageNamed:@"icon1"] forState:UIControlStateNormal];
    icon.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:icon];
    self.icon = icon;
    
    //nickName
    UILabel *lable = [[UILabel alloc] init];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.backgroundColor = [UIColor clearColor];
    lable.font = [UIFont systemFontOfSize:14.0];
    lable.textColor = [UIColor blackColor];
    lable.adjustsFontSizeToFitWidth = YES;
    [self addSubview:lable];
    _nickName = lable;
}

- (void)configOwnViews
{
    //icon
    CGRect rect = self.bounds;
    CGFloat iconWH = 50;
    CGFloat iconX = (rect.size.width - iconWH) * 0.5;
    CGFloat icony = (rect.size.height - iconWH) * 0.5;
    self.icon.frame = CGRectMake(iconX, icony, iconWH, iconWH);
    self.icon.layer.cornerRadius = iconWH * 0.5;
    
    //nickName
    CGFloat lableH = 21;
    CGFloat lableY = self.bounds.size.height - lableH;
    _nickName.frame = CGRectMake(0, lableY, self.bounds.size.width, lableH);
}

#pragma mark - Public

- (void)setProgressWidth:(CGFloat)progressWidth
{
    _progressWidth = progressWidth;
    self.shapeLayer.lineWidth = progressWidth;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    self.shapeLayer.strokeColor = progressColor.CGColor;
}

- (void)setProgressValue:(CGFloat)value
{
    _progressValue = MAX(0.0, MIN(1.0, value));
    self.shapeLayer.strokeEnd += _progressValue;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.icon addTarget:target action:action forControlEvents:controlEvents];
}

@end
