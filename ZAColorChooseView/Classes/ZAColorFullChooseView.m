//
//  ZAColorFullChooseView.m
//  TestRound
//
//  Created by zhuoapp on 15/12/16.
//  Copyright © 2015年 zhuoapp. All rights reserved.
//

#import "ZAColorFullChooseView.h"
#define FullColorImagePath  SingleImagePath((currentColorArray.count))
#define InnerShadowImagePath SingleImagePath((currentColorArray.count+1))

@implementation ZAColorFullChooseView

 
#pragma mark - 带渐变的色盘F
-(instancetype)initGradientWithFrame:(CGRect)frame  colorArray:(NSArray *)colorArray
{
    self=[super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    currentColorArray=colorArray;
    radius=(CGRectGetWidth(frame)>CGRectGetHeight(frame)?CGRectGetHeight(frame):CGRectGetWidth(frame))/2;
    fanShapedCount=colorArray.count;
    center=CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
    needScaleWhenChoose=YES;
    [self drawPicWithFrame:frame colorArray:colorArray];
    
    for (int i=0; i<colorArray.count+1; i++) {
        NSString *path=NSHomeDirectory();
        path=SingleImagePath(i);
        UIImage *image=[UIImage imageWithContentsOfFile:path];
        
        
        CAShapeLayer *layer;
        
        if (i<colorArray.count) {
            
            float startAngle=[self fanSharpStartAngleWithTag :i];
            float endAngle=[self fanSharpEndAngleWithTag:i];
            layer=[self addFanShapeLayerWithStartAngle:startAngle endAngle:endAngle radius:radius color:colorArray[i]];
        }
        
        layer.fillColor=[UIColor clearColor].CGColor;
        layer.strokeColor=[UIColor clearColor].CGColor;
        layer.contents=(__bridge id _Nullable)(image.CGImage);
        
        if (i>colorArray.count-1) {
            //添加指针等转盘
            CALayer *layer=[CALayer layer];
            layer.bounds=self.frame;
            layer.contents=(__bridge id _Nullable)(image.CGImage);
            [self.layer addSublayer:layer];
            
            layer.position=CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
            
            
            if (i==colorArray.count) {
                [self addInnerShadowLayerWithImagePath:InnerShadowImagePath];
                [self addPointerLayer];
                [self addTouchEvent];
            }
        }
    }
    
    return self;
}

-(void)drawPicWithFrame:(CGRect)frame  colorArray:(NSArray *)colorArray
{
    BOOL firstDraw=NO;
    NSMutableArray *contentArray=[[NSUserDefaults standardUserDefaults]objectForKey:@"draw"];
    NSMutableArray *dataArray=[[NSMutableArray alloc]init];
    BOOL has=YES;
    for (UIColor *color in  colorArray) {
        NSData *data=[NSKeyedArchiver archivedDataWithRootObject:color];
        [dataArray addObject:data];
        if (!contentArray || ![contentArray containsObject:data]) {
            has=NO;
        }
    }
    
    if (!has) {
        [[NSUserDefaults standardUserDefaults]setValue:dataArray forKey:@"draw"];
        firstDraw=YES;
    }
    
    if (!firstDraw) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    CAShapeLayer *innerShadowLayer=[CAShapeLayer layer];
    for (int i=0; i<colorArray.count+2; i++) {
        
        NSString *path=SingleImagePath(i);
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, [[UIScreen mainScreen] scale]);
        if (i<colorArray.count) {
            float startAngle=[self fanSharpStartAngleWithTag :i];
            float endAngle=[self fanSharpEndAngleWithTag:i];
            
            CAShapeLayer *layer=[self addFanShapeLayerWithStartAngle:startAngle endAngle:endAngle radius:radius color:colorArray[i]];
            //添加渐变与外圈阴影
            [self addGradientToLayerWithStartAngle:startAngle endAngle:endAngle color:colorArray[i] layer:layer];
            //内径加阴影
            HSVType hsv=[self converColorToHSV:colorArray[i]];
            [self addShadowColorWithStartAngle:startAngle endAngle:endAngle innnerOrOut:YES layer:innerShadowLayer hsv:hsv positon:StartPosition];
            [self.layer addSublayer:layer];
            [layer renderInContext:UIGraphicsGetCurrentContext()];
        }else if (i==colorArray.count){
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        }else{
            [innerShadowLayer renderInContext:UIGraphicsGetCurrentContext()];
        }
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *data=UIImagePNGRepresentation(newImage);
        [data writeToFile:path atomically:YES];
    }
    
    NSArray *array=[[NSArray alloc]initWithArray:self.layer.sublayers];
    for (CAShapeLayer *layer in array  ) {
        if (layer) {
            [layer removeFromSuperlayer];
        }
    }
    
    NSArray *array1=[[NSArray alloc]initWithArray:innerShadowLayer.sublayers];
    for (CAShapeLayer *layer in array1  ) {
        if (layer) {
            [layer removeFromSuperlayer];
        }
    }
    
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"%@",error.description);
    }else
    {
        //        [MBProgressHUD showMessage:@"保存成功！"];
        NSLog(@"保存成功！");
    }
}





@end
