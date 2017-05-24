//
//  ZAViewController.m
//  ZAColorChooseView
//
//  Created by chuting on 08/30/2016.
//  Copyright (c) 2016 chuting. All rights reserved.
//

#import "ZAViewController.h"
#import "ZAColorFullChooseView.h"

@interface ZAViewController ()<ColorChangeDelegate>

@end

@implementation ZAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    NSArray *colorArray = @[[UIColor colorWithRed:247/255.0 green:40/255.0 blue:141/255.0 alpha:1], [UIColor colorWithRed:176/255.0 green:27/255.0 blue:190/255.0 alpha:1],[UIColor colorWithRed:0 green:0 blue:255/255.0 alpha:1 ],[UIColor colorWithRed:0 green:177/255.0 blue:218/255.0 alpha:1 ],[UIColor colorWithRed:0/255.0 green:228/255.0 blue:139/255.0 alpha:1], [UIColor colorWithRed:89/255.0 green:254/255.0 blue:1/255.0 alpha:1], [UIColor colorWithRed:175/255.0 green:254/255.0 blue:28/255.0 alpha:1],[UIColor colorWithRed:253/255.0 green:253/255.0 blue:23/255.0 alpha:1],  [UIColor colorWithRed:253/255.0 green:215/255.0 blue:55/255.0 alpha:1],[UIColor colorWithRed:251/255.0 green:178/255.0 blue:45/255.0 alpha:1], [UIColor colorWithRed:248 /255.0 green:106 /255.0 blue:32/255.0 alpha:1],[UIColor colorWithRed:255/255.0 green:0 blue:0 alpha:1 ]];
    

    
    ZAColorFullChooseView *colorView = [[ZAColorFullChooseView alloc]initGradientWithFrame:CGRectMake(kscreenWidth*0.1, 80, kscreenWidth*0.8, kscreenWidth*0.8) colorArray:colorArray];
    colorView.delegate = self;
    [self.view addSubview:colorView];
    
    [colorView setColor:[UIColor colorWithRed:255/255.0 green:0 blue:0 alpha:1 ]];
    
    UIImageView *chooseColorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kscreenWidth-80, 40, 40, 20)];
    chooseColorImageView.tag = 1000;
    [self.view addSubview:chooseColorImageView];
    
    
}


-(void)colorChangeWithColor:(UIColor *)color colorChooseView:(ZAColorChooseView *)colorChooseView
{
    UIImageView *chooseColorImageView = [self.view viewWithTag:1000];
    chooseColorImageView.backgroundColor = colorChooseView.color;
}


-(void)colorChangeStopWithColor:(UIColor *)color colorChooseView:(ZAColorChooseView *)colorChooseView
{



}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
