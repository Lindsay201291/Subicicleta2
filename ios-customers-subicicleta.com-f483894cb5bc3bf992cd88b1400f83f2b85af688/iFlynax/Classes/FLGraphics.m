//
//  FLGraphics.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 12/8/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLGraphics.h"

@implementation FLContextPainter

#pragma mark - Initialization

- (instancetype) initWithContext:(CGContextRef)context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (instancetype) initWithCurrentContext {
    return [self initWithContext:UIGraphicsGetCurrentContext()];
}


#pragma mark - Drawing

- (void)strokeLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withColor:(UIColor *)color andLineWidth:(CGFloat)width {
    CGContextSetStrokeColorWithColor(self.context, color.CGColor);
    CGContextSetLineWidth(self.context, width);
    CGContextMoveToPoint(self.context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(self.context, endPoint.x, endPoint.y);
    CGContextStrokePath(self.context);
}

- (void)strokeRect:(CGRect)rect withColor:(UIColor *)color andLineWidth:(CGFloat)width {
    CGContextSetStrokeColorWithColor(self.context, color.CGColor);
    CGContextSetLineWidth(self.context, width);
    CGContextMoveToPoint(self.context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(self.context, rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(self.context, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(self.context, rect.origin.x, rect.size.height);
    CGContextAddLineToPoint(self.context, rect.origin.y, rect.origin.y);
    
    //CGContextAddRect(self.context, rect);
    CGContextStrokePath(self.context);
}

- (void)fillRect:(CGRect)rect withColor:(UIColor *)color {
    CGContextSetFillColorWithColor(self.context, color.CGColor);
    CGContextAddRect(self.context, rect);
    CGContextFillPath(self.context);
}

- (void)linearGraientWithRect:(CGRect)rect fromColor:(UIColor *)starColor toColor:(UIColor *)endColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[ (__bridge id)starColor.CGColor, (__bridge id)endColor.CGColor ];

    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(self.context);
    
    CGContextAddRect(self.context, rect);
    CGContextClip(self.context);
    
    CGContextDrawLinearGradient(self.context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(self.context);
    
    CFRelease(gradient);
    CFRelease(colorSpace);
 
}

@end
