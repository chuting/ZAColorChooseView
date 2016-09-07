//
//  ZAColorFullChooseView.h
//  TestRound
//
//  Created by zhuoapp on 15/12/16.
//  Copyright © 2015年 zhuoapp. All rights reserved.
//

#import "ZAColorChooseView.h"


@interface ZAColorFullChooseView : ZAColorChooseView



#pragma mark - 带渐变的色盘
/**
 *  带渐变的色盘
 *
 *  @param frame      <#frame description#>
 *  @param colorArray <#colorArray description#>
 *
 *  @return <#return value description#>
 */
-(instancetype)initGradientWithFrame:(CGRect)frame  colorArray:(NSArray *)colorArray;




@end
