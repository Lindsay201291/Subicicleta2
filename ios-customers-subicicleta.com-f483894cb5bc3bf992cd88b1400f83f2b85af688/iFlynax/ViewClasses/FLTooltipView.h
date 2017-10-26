//
//  FLTooltipView.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 3/10/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

typedef NS_OPTIONS(NSInteger, FLTooltipArrowPos) {
    FLTooltipArrowPosCenter  = 1 << 0,
    FLTooltipArrowPosTop     = 1 << 1,
    FLTooltipArrowPosBottom  = 1 << 2,
    FLTooltipArrowPosLeft    = 1 << 3,
    FLTooltipArrowPosRight   = 1 << 4,
};

@interface FLTooltipView : UIView

@property (nonatomic) FLTooltipArrowPos arrowPosOptions;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic) CGFloat arrowShift;
@property (nonatomic) CGSize arrowSize;
@property (nonatomic) CGFloat messageLabelMargin;
@property (nonatomic) NSTimeInterval fadeInterval;

- (instancetype)initWithMessage:(NSString *)message withColor:(UIColor*)color withArrowPosOptions:(FLTooltipArrowPos)options;

- (void)fadeInWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)fadeOutWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)show;
- (void)hide;
- (void)fadeOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion;

@end