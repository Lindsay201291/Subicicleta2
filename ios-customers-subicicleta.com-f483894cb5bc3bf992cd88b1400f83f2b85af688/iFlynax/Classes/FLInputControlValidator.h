//
//  FLInputControlValidator.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//
#import "FLTooltipView.h"
#import "FLValider.h"

typedef NS_OPTIONS(NSInteger, FLValidatorTooltipPos) {
    FLValidatorTooltipPosAbove  = 1 << 0,
    FLValidatorTooltipPosBelow  = 1 << 1,
    FLValidatorTooltipPosLeft   = 1 << 2,
    FLValidatorTooltipPosCenter = 1 << 3,
    FLValidatorTooltipPosRight  = 1 << 4
};

@interface FLInputControlValidator : NSObject<UITextFieldDelegate>

@property (nonatomic, readonly, strong) id inputControl;
@property (nonatomic) BOOL isValid;
@property (nonatomic) FLValider *actualValider;
@property (nonatomic) FLTooltipView *tooltip;
@property (nonatomic, copy) NSString *tooltipMessage;
@property (nonatomic) FLValidatorTooltipPos tooltipPos;
@property (nonatomic) CGFloat tooltipIndent;

+ (instancetype)validerWithInputControll:(UIView *)control withValider:(NSArray *)validers;

- (instancetype)initWithInputControll:(UIView *)control withValider:(NSArray *)validers;

- (void)validate;
- (void)manageTooltipMessage;
- (void)showTooltip;
- (void)showHideTooltipInDelay:(CGFloat)delay;
- (void)hideTooltip;

@end
