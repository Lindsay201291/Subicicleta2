//
//  FLPhotosCount.m
//  iFlynax
//
//  Created by Alex on 11/11/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLPhotosCount.h"

@interface FLPhotosCount ()
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@end

@implementation FLPhotosCount

- (void)awakeFromNib {
    [super awakeFromNib];

	self.backgroundColor = [UIColor clearColor];
	_countLabel.textColor = [UIColor hexColor:kColorFLPhotosCountText];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGFloat width = CGRectGetWidth(rect)*2;
	CGFloat height = CGRectGetHeight(rect)*2;
    CGFloat xPos = IS_RTL ? 0 : -width/2;
	CGRect ellipseRect = CGRectMake(xPos, -height/2, width, height);
	CGColorRef backgroundColor = [UIColor hexColor:kColorThemeGlobal].CGColor;
	// draw ellipse
	CGContextAddEllipseInRect(ctx, ellipseRect);
	CGContextSetFillColor(ctx, CGColorGetComponents(backgroundColor));
	CGContextFillPath(ctx);
}

#pragma mark - setters

- (void)setCount:(NSInteger)count {
	_count = count;
    _countLabel.text = F(@"%@", @(_count));
}

- (void)setHideWhenZero:(BOOL)hideWhenZero {
    _hideWhenZero = hideWhenZero;
    self.hidden = (_count == 0 && hideWhenZero);
}

@end
