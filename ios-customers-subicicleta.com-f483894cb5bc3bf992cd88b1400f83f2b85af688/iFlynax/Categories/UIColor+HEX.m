//
//  UIColor+HEX.m
//  iFlynax
//
//  Created by Alex on 4/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "UIColor+HEX.h"

@implementation UIColor (HEX)


+ (UIColor *)hexColor:(NSString *)hexString {
	return [UIColor hexColor:hexString alpha:1.0];
}

+ (UIColor *)hexColor:(NSString *)hexString alpha:(CGFloat)alpha {
	unsigned rgbValue = 0;

	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner scanHexInt:&rgbValue];

	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0
						   green:((rgbValue & 0xFF00) >> 8) / 255.0
							blue:(rgbValue & 0xFF) / 255.0
						   alpha:alpha];
}

@end