//
//  FLPlanCell.m
//  iFlynax
//
//  Created by Alex on 11/18/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLPlanCell.h"

@implementation FLPlanCell

- (void)awakeFromNib {
    [super awakeFromNib];

	self.backgroundColor = [UIColor redColor];
}

- (void)drawRect:(CGRect)rect {
	UIBezierPath *bezierPath;
	
	//Draw left line
	bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(0.0f, 0.0f)];
	[bezierPath addLineToPoint:CGPointMake(10.0f, 0.0f)];
	[[UIColor hexColor:@"0099cc"] setStroke];
	[bezierPath setLineWidth:CGRectGetHeight(rect)*2];
	[bezierPath stroke];
	CGFloat test;
	[bezierPath setLineDash:&test count:5 phase:2];
}

@end
