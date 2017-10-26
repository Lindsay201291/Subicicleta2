//
//  FLTooltipView.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 3/10/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTooltipView.h"

@implementation FLTooltipView {
    UIView *_arrowView;
    CAShapeLayer *_arrowLayer;
    NSTimer *_delayTimer;
}

- (instancetype)init {
    return [self initWithMessage:@"message"
                       withColor:[UIColor redColor]
             withArrowPosOptions:FLTooltipArrowPosTop | FLTooltipArrowPosCenter];
}

- (instancetype)initWithMessage:(NSString *)message withColor:(UIColor*)color withArrowPosOptions:(FLTooltipArrowPos)options {
    self = [super init];
    if (self) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_messageLabel];
        
        _arrowView = [[UIView alloc] init];
        _arrowView.translatesAutoresizingMaskIntoConstraints = NO;
        _arrowView.backgroundColor = [UIColor clearColor];
        
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.backgroundColor = [UIColor clearColor].CGColor;
        [_arrowView.layer addSublayer:_arrowLayer];
        [self addSubview:_arrowView];
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius  = 2;
        self.layer.shadowOffset  = CGSizeMake(0, 2);
        self.layer.shadowRadius  = 2;
        self.layer.shadowOpacity = .5f;
        
        self.arrowShift         = 20;
        self.messageLabelMargin = 5;
        self.arrowSize          = CGSizeMake(16, 8);
        self.arrowPosOptions    = options;
        self.message            = message;
        self.backgroundColor    = color;
    }
    return self;
}

- (void)setArrowPosOptions:(FLTooltipArrowPos)options {
    _arrowPosOptions = options;
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    if (_arrowPosOptions & FLTooltipArrowPosBottom) {
        [arrowPath moveToPoint:CGPointMake(0, 0)];
        [arrowPath addLineToPoint:CGPointMake(_arrowSize.width / 2, _arrowSize.height)];
        [arrowPath addLineToPoint:CGPointMake(_arrowSize.width, 0)];
    }
    else {
        [arrowPath moveToPoint:CGPointMake(0, _arrowSize.height)];
        [arrowPath addLineToPoint:CGPointMake(_arrowSize.width / 2, 0)];
        [arrowPath addLineToPoint:CGPointMake(_arrowSize.width, _arrowSize.height)];
    }
    [arrowPath closePath];
    _arrowLayer.path = arrowPath.CGPath;
    [self setNeedsUpdateConstraints];
}

- (void)setArrowSize:(CGSize)arrowSize {
    _arrowSize = arrowSize;
    
    _arrowLayer.frame = CGRectMake(0, 0, _arrowSize.width, _arrowSize.height);
    
    [_arrowView removeConstraints:_arrowView.constraints];
    
    [_arrowView addConstraint:[NSLayoutConstraint constraintWithItem:_arrowView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:_arrowSize.width]];
    
    [_arrowView addConstraint:[NSLayoutConstraint constraintWithItem:_arrowView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:_arrowSize.height]];
    self.arrowPosOptions = _arrowPosOptions;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _arrowLayer.fillColor = backgroundColor.CGColor;
}

- (void)setMessage:(NSString *)message {
    _messageLabel.text = message;
    _message = message;
}

- (void)setMessageLabelMargin:(CGFloat)margin {
    _messageLabelMargin = margin;
    [self setNeedsUpdateConstraints];
}

- (void)setArrowShift:(CGFloat)arrowShift {
    _arrowShift = arrowShift;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self removeConstraints:self.constraints];
    
    //message label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1
                                                      constant:_messageLabelMargin]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:_messageLabelMargin]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1
                                                      constant:-_messageLabelMargin]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_messageLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:_messageLabelMargin]];
    //arrow view
    CGFloat contraintConstant = _arrowShift;
    NSLayoutAttribute layoutAttribute1;
    NSLayoutAttribute layoutAttribute2;
    
    layoutAttribute1 = NSLayoutAttributeLeading;
    
    if (_arrowPosOptions & FLTooltipArrowPosRight) {
        layoutAttribute1 = NSLayoutAttributeTrailing;
        contraintConstant = 0 - _arrowShift;
    }
    else if (_arrowPosOptions & FLTooltipArrowPosCenter) {
        layoutAttribute1 = NSLayoutAttributeCenterX;
        contraintConstant = 0;
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_arrowView
                                                     attribute:layoutAttribute1
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:layoutAttribute1
                                                    multiplier:1
                                                      constant:contraintConstant]];
    
    layoutAttribute1 = NSLayoutAttributeBottom;
    layoutAttribute2 = NSLayoutAttributeTop;
    
    if (_arrowPosOptions & FLTooltipArrowPosBottom) {
        layoutAttribute1 = NSLayoutAttributeTop;
        layoutAttribute2 = NSLayoutAttributeBottom;
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_arrowView
                                                     attribute:layoutAttribute1
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:layoutAttribute2
                                                    multiplier:1
                                                      constant:0]];
    
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    self.alpha = 1;
    [UIView animateWithDuration:duration
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

- (void)fadeInWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:duration
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL))completion {
    if (_delayTimer) {
        [_delayTimer invalidate];
    }
    
    
    _delayTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                   target:self
                                                 selector:@selector(handleDelayTimer:)
                                                 userInfo:@(duration)
                                                  repeats:NO];
}

- (void)handleDelayTimer:(NSTimer *)timer {
    [self fadeOutWithDuration:[(NSNumber *)timer.userInfo doubleValue] completion:nil];
}

- (void)hide {
    self.alpha = 0;
    self.hidden = YES;
}

- (void)show {
    self.alpha = 1;
    self.hidden = NO;
}

@end
