//
//  FLRatingStars.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 8/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLRatingStars.h"

@interface FLRatingStars ()

@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) CGFloat outerRadius;
@property (nonatomic) CGFloat fixedRating;
@property (nonatomic) CALayer *fillLayer;
@property (nonatomic) CGFloat horMargin;

@end

@implementation FLRatingStars

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaultSettings];
    }
    return self;
}

- (void)setStarDepth:(CGFloat)depth {
    if (depth > 1)
        _starDepth = 1;
    else if (depth < 0)
        _starDepth = 0;
    else
        _starDepth = depth;
}

- (void)setDefaultSettings {
    self.multipleTouchEnabled   = NO;
    
    _backColor = [UIColor whiteColor];
    _fillColor = [UIColor blackColor];
    _starDepth = .58;
    _starsNumber = 5;
    _starAnglesNumber = 5;
    _starsSpacing = 2;
    _strokeWidth = 1;
    _rating = 0;
}

- (void)drawRect:(CGRect)rect {
    
    CALayer *layer = [CALayer layer];
    layer.frame = self.bounds;
    layer.backgroundColor = _backColor.CGColor;
    
    if (_rating > _starsNumber)
        _rating = _starsNumber;
    else if (_rating < 0)
        _rating = 0;
    
    _outerRadius = MIN((self.bounds.size.width - _starsSpacing * (_starsNumber - 1)) / _starsNumber, self.bounds.size.height) / 2;
    _innerRadius = _outerRadius * (1 - _starDepth);
    
    _horMargin = (self.bounds.size.width - _outerRadius * 2 * _starsNumber - _starsSpacing * (_starsNumber - 1)) / 2;
    
    CGFloat steps       = _starAnglesNumber * 2;
    CGFloat stepAngle   = 2 * M_PI / steps;
    CGPoint centerPoint = CGPointMake(_horMargin + _outerRadius, self.bounds.size.height / 2);
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *maskPath  = [UIBezierPath bezierPath];
    
    for (int si = 1; si <= _starsNumber; si++) {
        for (int ai = 0; ai <= steps; ai++) {
            CGFloat radius = ai % 2 == 0 ? _outerRadius : _innerRadius;
            CGFloat angle  = ai * stepAngle - M_PI_2;
            CGPoint point  = CGPointMake(radius * cos(angle) + centerPoint.x,
                                         radius * sin(angle) + centerPoint.y);
            
            if (ai == 0)
                [maskPath moveToPoint:point];
            else
                [maskPath addLineToPoint:point];
            
        }
        centerPoint.x += _outerRadius * 2 + _starsSpacing;
    }
    
    [maskPath closePath];
    
    maskLayer.path = maskPath.CGPath;
    layer.mask = maskLayer;
    
    if (_gradientCGColors) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = _gradientCGColors;
        _fillLayer = gradientLayer;
    }
    else {
        CAShapeLayer *contentLayer = [CAShapeLayer layer];
        contentLayer.backgroundColor = _fillColor.CGColor;
        _fillLayer = contentLayer;
    }
    
    [layer addSublayer:_fillLayer];
    
    [self showRating];
    
    if (_strokeColor) {
        CAShapeLayer *strokeLayer = [CAShapeLayer layer];
        strokeLayer.frame = self.bounds;
        strokeLayer.path = maskPath.CGPath;
        strokeLayer.lineWidth = _strokeWidth;
        strokeLayer.strokeColor = _strokeColor.CGColor;
        strokeLayer.fillColor = [UIColor clearColor].CGColor;
        [layer addSublayer:strokeLayer];
    }
    
    [self.layer addSublayer:layer];
}

- (void)showRating {
    CGRect fillRect = CGRectMake(0, 0, _horMargin + _outerRadius * 2 * _rating + _starsSpacing * floor(_rating), self.bounds.size.height);
    _fillLayer.frame = fillRect;
}

- (void)fixRatingByTouchPoint:(CGPoint)point {
    if (point.x < _horMargin) {
        _rating = 0;
    }
    else if (point.x > self.bounds.size.width - _horMargin) {
        _rating = _starsNumber;
    }
    else {
        for (int i = 1; i <= _starsNumber; i++) {
            CGFloat starRightX = _horMargin + 2 * _outerRadius * i + (i - 1) * _starsSpacing;
            CGFloat starLeftX  = starRightX - 2 * _outerRadius;
            if  (point.x > starLeftX && point.x < starRightX) {
                _rating = i;
                break;
            }
        }
    }
    
    [self showRating];
}

#pragma mark - Touches handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    [self fixRatingByTouchPoint:touchPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    [self fixRatingByTouchPoint:touchPoint];
}

@end
