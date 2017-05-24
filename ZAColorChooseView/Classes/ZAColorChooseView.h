//
//  ZAColorChooseView.h
//  TestRound
//
//  Created by zhuoapp on 15/12/11.
//  Copyright © 2015年 zhuoapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSV.h"


#define SingleImagePath(tag) [NSString stringWithFormat:@"%@/Documents/%zd.png",NSHomeDirectory(),tag]

@class ZAColorChooseView;


//屏幕宽高定义
#define kscreenWidth   [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

//尺寸缩放  6为1.17倍 6p为1.29倍
#define convertSpace(height)     (((kScreenHeight==667)||(kScreenHeight==736))?( ( kScreenHeight==667)?height*1.17:height*1.29):  height )

//除外阴影宽度外的渐变色占用比
#define FullPosition 0.95
//#define ShadowPosition 0.85
#define StartPosition   (int)( self.pointImage.size.width/2)*0.9
//未选中动画过程中色块的缩放比
#define AnimateTransformScale 1.08
//选中色块缩放比
#define AnimateEndTransformScale 1.18
//内阴影宽度
#define InnerShadowRadius convertSpace(4)




@protocol ColorChangeDelegate <NSObject>

/**
 *  颜色发生变化的时候调用
 *
 *  @param color <#color description#>
 */
-(void)colorChangeWithColor:(UIColor *)color  colorChooseView:(ZAColorChooseView *)colorChooseView;

/**
 *  停止触摸的时候调用
 *
 *  @param color <#color description#>
 */
-(void)colorChangeStopWithColor:(UIColor *)color colorChooseView:(ZAColorChooseView *)colorChooseView;

@end

@interface ZAColorChooseView : UIView
{

    int radius;
    CGFloat fanShapedCount;
    CGPoint center;
    
    CALayer *pointLayer;
//     CALayer *pointSuperLayer;
    //内圈阴影
//    CAShapeLayer *innerShadowLayer;
    
    NSMutableArray <UIBezierPath *> *bezierPathArray;
    NSMutableArray <CAShapeLayer *> *layerArray;
    
    CAShapeLayer *lastLayer;
    
    NSInteger lastChooseTag;
    NSInteger lastTag;
    UIColor *currentColor;
    
    NSArray *currentColorArray;
    
    BOOL needScaleWhenChoose;
    
    BOOL isFirst;
    
}

@property (nonatomic,weak) UIImage *pointImage;
@property (nonatomic,weak) id <ColorChangeDelegate> delegate;
@property (nonatomic,assign) NSInteger lastChooseTag;
@property (nonatomic,weak,getter=getColor) UIColor *color;

#pragma mark -  不带渐变的色盘，
/**
 *   不带渐变的色盘，
 *
 *  @param frame      <#frame description#>
 *  @param colorArray <#colorArray description#>
 *
 *  @return <#return value description#>
 */
-(instancetype)initWithFrame:(CGRect)frame  colorArray:(NSArray *)colorArray;



#pragma mark - 设置颜色 带动画效果
/**
 *  设置颜色 带动画效果
 *
 *  @param color <#color description#>
 */
-(void)setColor:(UIColor *)color;





#pragma mark - 大的扇形
/**
 *  画扇形
 *
 *  @param startRadius 去
 *  @param endRadius   <#endRadius description#>
 *  @param radius1     <#radius1 description#>
 *
 *  @return <#return value description#>
 */
-(UIBezierPath *)sharpPathWithStartAngle:(float)startAngle endAngle:(float)endAngle  radius:(float)radius1;
/**
 *  <#Description#>
 *
 *  @param startAngle <#startAngle description#>
 *  @param endAngle   <#endAngle description#>
 *  @param radius1    <#radius1 description#>
 *  @param color      <#color description#>
 *
 *  @return <#return value description#>
 */
-(CAShapeLayer *)addFanShapeLayerWithStartAngle:(float)startAngle endAngle:(float)endAngle radius:(float)radius1 color:(UIColor *)color;
#pragma mark - 在单个扇形上面加渐变
/**
 *  <#Description#>
 *
 *  @param startAngle <#startAngle description#>
 *  @param endAngle   <#endAngle description#>
 *  @param color      <#color description#>
 *  @param layer      <#layer description#>
 */
-(void)addGradientToLayerWithStartAngle:(float)startAngle endAngle:(float)endAngle  color:(UIColor *)color  layer:(CAShapeLayer *)layer;
/**
 *  <#Description#>
 * 
 *  @param startRadius <#startRadius description#>
 *  @param endRadius   <#endRadius description#>
 *  @param innnerOrOut <#innnerOrOut description#>
 *  @param layer       <#layer description#>
 *  @param hsv         <#hsv description#>
 *  @param postion     <#postion description#>
 */
-(void)addShadowColorWithStartAngle:(float)startAngle endAngle:(float)endAngle  innnerOrOut:(BOOL)innnerOrOut  layer:(CAShapeLayer *)layer  hsv:(HSVType)hsv positon:(float)postion;


#pragma mark  添加渐变的弧线
/**
 *  添加渐变的弧线
 *
 *  @param currentCenter 圆心
 *  @param innerRadius   到圆心的距离
 *  @param width         弧线的宽度
 *  @param startRadius   开始角度  格式：M_PI**
 *  @param endRadius     结束角度  格式：M_PI**
 *  @param hsv           需要渐变的颜色 传用hsv显示
 *
 *  @return <#return value description#>
 */
-(CAShapeLayer *)addSingleRadiusWithCenter:(CGPoint)currentCenter innerRadius:(float)innerRadius width:(float)width  start:(float)startRadius end:(float)endRadius hsv:(HSVType)hsv;

#pragma mark - 添加指针layer
/**
 *  添加指针layer  默认位置为圆心
 */
-(void)addPointerLayer;

#pragma mark - 添加内阴影
/**
 *  添加内阴影
 */
-(void)addInnerShadowLayerWithImagePath:(NSString *)innerShadowImagePath;


#pragma mark - 添加触摸事件
-(void)addTouchEvent;



-(float)singleAngle;
-(float)fanSharpStartAngleWithTag:(int)tag;
-(float)fanSharpEndAngleWithTag:(int)tag;

-(HSVType)converColorToHSV:(UIColor *)color;

-(void)setSelectTag:(int)tag;

-(void)startCloseAnimate;

@end
