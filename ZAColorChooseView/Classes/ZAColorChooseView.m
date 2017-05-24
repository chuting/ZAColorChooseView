 //
//  ZAColorChooseView.m
//  TestRound
//
//  Created by zhuoapp on 15/12/11.
//  Copyright © 2015年 zhuoapp. All rights reserved.
//

#import "ZAColorChooseView.h"



//外阴影宽度
//#define OutShadowRadius 2
//半径
//#define Radius   100
//扇形个数
//#define FanShapedCount 12

@implementation ZAColorChooseView
@synthesize delegate;
@synthesize lastChooseTag;
@synthesize pointImage ;
//@synthesize currentColor;


-(UIImage *)pointImage
{
    if (pointImage) {
        return pointImage;
    }
//    NSString *bundlePath=[[NSBundle mainBundle]bundlePath];
//    NSString *path= [bundlePath stringByAppendingPathComponent:@"ZAColorChooseView.bundle/color_choose_point@2x.png"];
    pointImage=[UIImage imageNamed:@"color_choose_point"];
    return pointImage;

}

-(instancetype)initWithFrame:(CGRect)frame  colorArray:(NSArray *)colorArray
{

    self=[super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    currentColorArray=colorArray;
    radius= (CGRectGetWidth(frame)>CGRectGetHeight(frame)?CGRectGetHeight(frame):CGRectGetWidth(frame))/2;
    fanShapedCount=colorArray.count;
    center=CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
    return self;
}





#pragma mark - 大的扇形
-(UIBezierPath *)sharpPathWithStartAngle:(float)startAngle endAngle:(float)endAngle  radius:(float)radius1;
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:center]; 
    [path addLineToPoint:CGPointMake(cos(startAngle)*radius1+center.x,  sin(startAngle)*radius1+center.y)];
    [path addArcWithCenter:center radius:radius1 startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path moveToPoint:CGPointMake((center.x+ cos(endAngle)*radius1), center.y+sin(endAngle)*radius1)];
    [path addLineToPoint:center];
    [path closePath]; 
    return path;
}





#pragma mark - 添加触摸事件
-(void)addTouchEvent
{
    UILongPressGestureRecognizer *longPressGestureRecognizer=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(pressGestureRecognizer:)];
    longPressGestureRecognizer.minimumPressDuration=0.0005;
    [self addGestureRecognizer:longPressGestureRecognizer];
}

#pragma mark - 触摸事件处理
-(void)pressGestureRecognizer:(UILongPressGestureRecognizer *)tap
{
   CGPoint point= [tap locationInView:self ];
    NSInteger tag=-1;
    for (UIBezierPath *path in bezierPathArray) {
        if ([path containsPoint:point]) {
            tag=[bezierPathArray indexOfObject:path];
            break;
        }
        
    }
    if(tag==-1 || ((tag==-1)&&(tap.state==UIGestureRecognizerStateEnded))) {
//        NSLog(@"在区域外面停止触摸");
        if (lastLayer&&(tap.state==UIGestureRecognizerStateEnded)) {
            lastChooseTag=lastTag;
//            [self animationStartWithLayer:lastLayer isEnd:YES];
            [self getcolorWithPoint:CGPointZero];
            [self dealColorChangeWithIsTouchEnd:YES];
            [self animationStartWithLayer:lastLayer isEnd:YES  ];
        }
        return;
        
    }
    CAShapeLayer *layer=layerArray[tag];
    //在选中的扇形区域上触摸获取详细的颜色
    if (tag==lastChooseTag || CGAffineTransformEqualToTransform(layer.affineTransform, CGAffineTransformMakeScale(AnimateEndTransformScale, AnimateEndTransformScale)))
    {
//      NSLog(@"在选中的扇形区域上触摸微调颜色");
        lastTag=tag;
        lastLayer=layer;
        lastChooseTag=tag;
        [self getcolorWithPoint:point];
    }else{
         lastChooseTag=-1;
//        lastChooseTag= tag;
//        NSLog(@"取消选中");
        if (lastLayer ) {
            lastLayer.affineTransform=CGAffineTransformIdentity; 
            [lastLayer removeFromSuperlayer];
        }
        //在非选中的区域上触摸，改变大的选中区域
//        NSLog(@"在非选中的区域上触摸，改变大的颜色");
        lastLayer=layer;
        lastTag=tag;
        [self getcolorWithPoint:CGPointZero];
        [self animationStartWithLayer:lastLayer isEnd:NO];
    }
    //处理颜色改变事件，
    [self dealColorChangeWithIsTouchEnd:NO];
    if (tap.state==UIGestureRecognizerStateEnded) { 
        lastChooseTag=tag;
        [self animationStartWithLayer:layer isEnd:YES];
        [self dealColorChangeWithIsTouchEnd:YES]; 

    }
}

#pragma mark - 动画效果
/**
 *  指针及色块的动画效果
 *
 *  @param layer 需要实现动画的layer
 *  @param isEnd isEnd传yes 则layer放大AnimateEndTransformScale倍，否则放大AnimateEndTransformScale倍
 */
-(void)animationStartWithLayer:(CAShapeLayer *)layer  isEnd:(BOOL)isEnd
{
    float  angle=[self fanSharpStartAngleWithTag:(int)lastTag]+[self singleAngle]/2+M_PI/2.0;
    float scale=isEnd? (needScaleWhenChoose?AnimateEndTransformScale:1):AnimateTransformScale;
    [UIView animateWithDuration:0.1 animations:^{
         self.userInteractionEnabled=NO;
        layer.affineTransform=CGAffineTransformMakeScale(scale,scale);
        layer.position=center;
        [self.layer addSublayer:layer];
        [self.layer insertSublayer:layer below:pointLayer];
        pointLayer.affineTransform=CGAffineTransformMakeRotation(angle);
    }completion:^(BOOL finished) {
        self.userInteractionEnabled=YES;
//        if (scale==1) {
//            
//            [layer removeFromSuperlayer];
//        }
    }];   
}

#pragma mark - 添加内阴影
/**
 *  添加内阴影
 */
-(void)addInnerShadowLayerWithImagePath:(NSString *)innerShadowImagePath
{
    UIImage *image=[UIImage imageWithContentsOfFile:innerShadowImagePath];
    CAShapeLayer *innerShadowLayer=[CAShapeLayer layer];
    innerShadowLayer.frame=CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    innerShadowLayer.contents=(__bridge id _Nullable)(image.CGImage);
    [self.layer addSublayer:innerShadowLayer]; 
}

#pragma mark - 添加指针layer
/**
 *  添加指针layer  默认位置为圆心
 */
-(void)addPointerLayer
{
     
    pointLayer=[CALayer layer];
    pointLayer.bounds=CGRectMake(0, 0, self.pointImage.size.width,self.pointImage.size.height);
    pointLayer.position=center;
    pointLayer.contents=(id)self.pointImage.CGImage;
    [self.layer addSublayer:pointLayer];
}



-(CAShapeLayer *)addFanShapeLayerWithStartAngle:(float)startAngle endAngle:(float)endAngle radius:(float)radius1 color:(UIColor *)color
{

    UIBezierPath *path=[self sharpPathWithStartAngle:startAngle endAngle:endAngle radius:radius1];
    //大的扇形Layer
    CAShapeLayer *layer=[CAShapeLayer layer];
    layer.frame=CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    layer.path=path.CGPath;
    layer.fillColor=color.CGColor;
    layer.strokeColor=color.CGColor;
//    [self.layer addSublayer:layer];    
    if (!bezierPathArray) {
        bezierPathArray=[[NSMutableArray alloc]init];
    }
    [bezierPathArray addObject:path];    
    if (!layerArray) {
        layerArray=[[NSMutableArray alloc]init];
    }
    [layerArray addObject:layer];    
    return layer;

}



#pragma mark - 在单个扇形上面加渐变
-(void)addGradientToLayerWithStartAngle:(float)startAngle endAngle:(float)endAngle  color:(UIColor *)color  layer:(CAShapeLayer *)layer{
//    const CGFloat *components = CGColorGetComponents(color.CGColor);
//    HSVType hsv= RGB_to_HSV(RGBTypeMake(components[0], components[1], components[2]));    
    float gap=1;
    int postion=radius*FullPosition;    
    HSVType hsv=[self converColorToHSV:color];    
    int  min= (AnimateEndTransformScale-1)*radius+1;
    for (int i=StartPosition-min; i<postion; i+=gap) {
        //画单个弧形实现渐变
        HSVType hsv1=[self dealColorWithDistance:i color:color];
        gap=(hsv1.s>hsv.s?(postion-i):gap);
        CAShapeLayer *layer1=[self addSingleRadiusWithCenter:center innerRadius:i width:gap start:startAngle end:endAngle hsv:hsv1];
        [layer addSublayer:layer1];

    }
    ///画外径阴影
     [self addShadowColorWithStartAngle:startAngle endAngle:endAngle innnerOrOut:NO layer:layer hsv:hsv positon:postion];
    //    //给layer加描边
    CAShapeLayer *layer1=[CAShapeLayer layer];
    layer1.path=layer.path;
    layer1.borderColor=[UIColor whiteColor].CGColor;
    layer1.strokeColor=[UIColor whiteColor].CGColor;
    layer1.lineWidth=1.5;
    layer1.fillColor=[UIColor clearColor].CGColor;
    [layer addSublayer:layer1];
    //
}


-(void)addShadowColorWithStartAngle:(float)startAngle endAngle:(float)endAngle  innnerOrOut:(BOOL)innnerOrOut  layer:(CAShapeLayer *)layer  hsv:(HSVType)hsv positon:(float)postion
{    
    if (innnerOrOut) {
        for (int i=postion; i<postion+InnerShadowRadius; i+=1) {
            //内径加阴影
            HSVType hsv1= HSVTypeMake(  hsv.h-0.01*(InnerShadowRadius -(i-StartPosition)),  (hsv.s-0.25)/(radius*FullPosition-StartPosition)*(i-StartPosition)+0.25, hsv.v);
            CAShapeLayer *layer1= [self addSingleRadiusWithCenter:center innerRadius:i width:0.5 start:startAngle end:endAngle hsv:hsv1];
            [layer addSublayer:layer1];
            layer1.opacity=0.5;
        }

    }else{
        for (float i=postion; i<radius-3; i+=0.5) {
            ///画外径阴影
            HSVType hsv1= HSVTypeMake(hsv.h-0.0025*(i-postion),hsv.s, hsv.v);
            CAShapeLayer *layer1=[self addSingleRadiusWithCenter:center innerRadius:i width:0.5  start:startAngle end:endAngle hsv:hsv1];
            [layer addSublayer:layer1];
        }
        
    }        
}

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
-(CAShapeLayer *)addSingleRadiusWithCenter:(CGPoint)currentCenter innerRadius:(float)innerRadius width:(float)width  start:(float)startRadius end:(float)endRadius hsv:(HSVType)hsv
{

    float outRadius=innerRadius+width;
    UIBezierPath *path1=[UIBezierPath bezierPath];
    [path1 addArcWithCenter:currentCenter radius:outRadius  startAngle:startRadius endAngle:endRadius clockwise:YES];
    [path1 addLineToPoint:CGPointMake((currentCenter.x+cos(endRadius)*innerRadius), currentCenter.x+sin(endRadius)*(innerRadius))];
    [path1 addArcWithCenter:currentCenter radius:innerRadius startAngle:endRadius endAngle:startRadius clockwise:NO];
    [path1 addLineToPoint:CGPointMake(cos(startRadius)*outRadius+currentCenter.x,  sin(startRadius)*outRadius+currentCenter.x)];
    [path1 closePath];    
    CAShapeLayer *layer1=[CAShapeLayer layer];
    layer1.path=path1.CGPath;
    layer1.fillColor=[UIColor colorWithHue:hsv.h  saturation:hsv.s  brightness:hsv.v  alpha:1].CGColor;
    layer1.strokeColor=[UIColor colorWithHue:hsv.h  saturation:hsv.s  brightness:hsv.v  alpha:1].CGColor;
    return layer1;
}


#pragma mark - 根据触摸点获取颜色 如果point传CGPointZero 则获取不渐变的颜色
/**
 *   根据触摸点获取颜色 如果point传CGPointZero 则获取不渐变的颜色
 *
 *  @param point 如果point传CGPointZero 获取不渐变的颜色,传正确的point 获取渐变的颜色
 */
-(void)getcolorWithPoint:(CGPoint)point
{
    
    if (lastTag<currentColorArray.count) {
        UIColor *color=currentColorArray[lastTag];
        currentColor=color;
    }
   
    if (CGPointEqualToPoint(point,CGPointZero)) {
        return;
    }
    float r=(point.x - center.x)*(point.x - center.x) + (point.y - center.y)*(point.y - center.y);
    r =sqrt(r)/AnimateEndTransformScale;
  
    HSVType newHsv=[self dealColorWithDistance:r color:currentColor];
    UIColor *color =[UIColor colorWithHue:newHsv.h saturation:newHsv.s brightness:newHsv.v alpha:1];
    
    currentColor = color;
}



#pragma mark - 根据到圆心的距离获取颜色
/**
 *  根据到圆心的距离获取颜色
 *
 *  @param r     到圆心的距离
 *  @param color 需要改变的颜色
 *
 *  @return <#return value description#>
 */
-(HSVType)dealColorWithDistance:(float)r  color:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    HSVType hsv= RGB_to_HSV(RGBTypeMake(components[0], components[1], components[2]));
    HSVType newHsv= HSVTypeMake(hsv.h,(hsv.s-0.25)/(radius*FullPosition-StartPosition)*(r-StartPosition)+0.25, hsv.v);
    newHsv.s=(newHsv.s>hsv.s?hsv.s:newHsv.s);    
    return newHsv;
}


#pragma mark - 处理颜色改变事件 调用协议
/**
 *   处理颜色改变事件 调用协议
 *
 *  @param touchEnd  传yes 调用colorChangeStopWithColor ； 传no 调用colorChangeWithColor
 */
-(void)dealColorChangeWithIsTouchEnd:(BOOL)touchEnd
{
 
    if (touchEnd) {
       if (delegate && [delegate respondsToSelector:@selector(colorChangeStopWithColor:colorChooseView:)]) {
            [delegate colorChangeStopWithColor:currentColor colorChooseView:self];
       }
    }else{
        if (delegate && [delegate respondsToSelector:@selector(colorChangeWithColor:colorChooseView:)]) {
            [delegate colorChangeWithColor:currentColor colorChooseView:self];
        }
    }
}


-(HSVType)converColorToHSV:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    HSVType hsv= RGB_to_HSV(RGBTypeMake(components[0], components[1], components[2]));
    return hsv;
}


-(void)setSelectTag:(int)tag
{
    if (lastChooseTag==lastTag) {
        return;
    }
    lastChooseTag=tag;
    currentColor=currentColorArray[tag];
//    NSLog(@" 当前 %zd  选中的 %zd",lastTag,lastChooseTag);
    NSInteger count=0;
    NSInteger start= lastTag+1;
    NSInteger end=(lastTag<lastChooseTag?lastChooseTag+1:((currentColorArray.count-lastTag)+lastTag+lastChooseTag+1));
    for (NSInteger i=start; i<end; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05*count * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (lastLayer) {
                [UIView animateWithDuration:0.12 animations:^{
                    lastLayer.affineTransform=CGAffineTransformIdentity;
                }];
            }
            NSInteger tag=i;
            if ( i>(currentColorArray.count-1)) {
                tag=i-currentColorArray.count;
            }
            CAShapeLayer *layer=[layerArray objectAtIndex:tag];
            lastTag=tag;
            [self animationStartWithLayer:layer isEnd:tag==lastChooseTag ];
            lastLayer=layer;
            
        });
        count++;
    }
}


-(void)startCloseAnimate
{
    for (CAShapeLayer *layer1 in layerArray) {
        [UIView animateWithDuration:0.12 animations:^{
            layer1.affineTransform=CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
        }];
    }        
}


-(void)setColor:(UIColor *)color
{
    currentColor=color;
    HSVType  colorHsv=[self converColorToHSV:color];
    BOOL has=NO;
    for (UIColor *color1 in currentColorArray) {
        HSVType hsv=[self converColorToHSV:color1];
        if (fabs(hsv.h-colorHsv.h)<0.01) { 
            has=YES;
            lastChooseTag=[currentColorArray indexOfObject:color1];
            currentColor=color1; 
            break;
        }
        
    }
    if (!has) {
        [self startCloseAnimate];
        lastChooseTag=-1;
        lastTag=-1;
        return;
    }
    
    if (lastChooseTag==lastTag) {
        return;
    }

    NSInteger start= lastTag+1;
    NSInteger end=(lastTag<lastChooseTag?lastChooseTag+1:((currentColorArray.count-lastTag)+lastTag+lastChooseTag+1));
   
    if (!has) {
        lastChooseTag=-1;
    }
    NSInteger count=0;
  
    for (NSInteger i=start; i<end; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05*count * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (lastLayer) {
                [UIView animateWithDuration:0.12 animations:^{
                    lastLayer.affineTransform=CGAffineTransformIdentity;
                }completion:^(BOOL finished) {
//                      [lastLayer removeFromSuperlayer];
                }];
            }
            NSInteger tag=i;
            if ( i>(currentColorArray.count-1)) {
                tag=i-currentColorArray.count;
            }
            CAShapeLayer *layer=[layerArray objectAtIndex:tag];
            lastTag=tag;
            [self animationStartWithLayer:layer isEnd:tag==lastChooseTag ];
           
            lastLayer=layer;
            if (!has && i==end-1) {
                [UIView animateWithDuration:0.12 animations:^{
                    lastLayer.affineTransform=CGAffineTransformIdentity;
                }completion:^(BOOL finished) {
                    
                    
                }];
            }
        });
        count++;
    }
}


-(UIColor *)getColor
{
    return currentColor;
}

-(float)singleAngle
{    
    float gapRadius=0;
    return ((2*M_PI-gapRadius*fanShapedCount)/fanShapedCount);
}

-(float)fanSharpStartAngleWithTag:(int)tag
{
    return  tag*[self singleAngle];
}

-(float)fanSharpEndAngleWithTag:(int)tag
{
    return  (tag+1)*[self singleAngle];
}


@end
