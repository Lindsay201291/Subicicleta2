//
//  FLGraphics.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 12/8/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLContextPainter : NSObject
@property (assign, nonatomic) CGContextRef context;

/**
 *	Description
 *	@param context context description
 *	@return return value description
 */
- (instancetype)initWithContext:(CGContextRef)context;

/**
 *	Description
 *	@return return value description
 */
- (instancetype)initWithCurrentContext;

/**
 *	Description
 *	@param point point description
 *	@param point point description
 *	@param color color description
 *	@param width width description
 */
- (void)strokeLineFromPoint:(CGPoint)point toPoint:(CGPoint)point withColor:(UIColor *)color andLineWidth:(CGFloat)width;

/**
 *	Description
 *	@param rect  rect description
 *	@param color color description
 *	@param width width description
 */
- (void)strokeRect:(CGRect)rect withColor:(UIColor *)color andLineWidth:(CGFloat)width;

/**
 *	Description
 *	@param rect  rect description
 *	@param color color description
 */
- (void)fillRect:(CGRect)rect withColor:(UIColor *)color;

/**
 *	Description
 *	@param rect  rect description
 *	@param color color description
 *	@param color color description
 */
- (void)linearGraientWithRect:(CGRect)rect fromColor:(UIColor *)color toColor:(UIColor *)color;

@end
