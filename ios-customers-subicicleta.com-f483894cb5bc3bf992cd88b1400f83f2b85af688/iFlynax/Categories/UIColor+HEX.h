//
//  UIColor+HEX.h
//  iFlynax
//
//  Created by Alex on 4/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HEX)

/**
 *  Create a UIColor from a hexadecimal string format
 *
 *  @param hexString - input like "00FF00"
 *
 *  @return UIColor
 */
+ (UIColor *)hexColor:(NSString *)hexString;

/**
 *  Create a UIColor from a hexadecimal string format
 *
 *  @param hexString input like "00FF00"
 *  @param alpha     input like 1.0, 0.5, etc..
 *
 *  @return UIColor
 */
+ (UIColor *)hexColor:(NSString *)hexString alpha:(CGFloat)alpha;
@end