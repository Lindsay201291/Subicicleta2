//
//  FLInputControlValidator.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLInputControlValidator.h"
#import "FLDropDown.h"

CGFloat const kDefaultTooltipAnimationDuration = .3f;
CGFloat const kDefaultTooltipIndent            = 2.0f;
CGFloat const kDefaultShowHideDelay            = 5.0f;

@interface FLInputControlValidator ()<UITextViewDelegate>

@property (nonatomic, copy) NSMutableArray *validers;

@end

@implementation FLInputControlValidator {
    NSLayoutConstraint *_verticalContsraint;
    NSLayoutConstraint *_horizontalConstrant;
    NSString *_changeNotificationName;
    BOOL _autoValidation;
}

#pragma mark - Class methods

+ (instancetype)validerWithInputControll:(UIView *)control withValider:(NSArray *)validers {
    return [[self alloc] initWithInputControll:control withValider:validers];
}

#pragma mark - Initializers

- (instancetype)initWithInputControll:(UITextField *)control withValider:(NSArray *)validers {
    self = [super init];
    if (self) {
        _inputControl = control;
        _validers     = [validers mutableCopy];
        _autoValidation = NO;
        
        [self addTooltip];
        
        [self defineProperEvents];
    }
    return self;
}

- (void)addTooltip {
    _tooltip = [[FLTooltipView alloc] init];
    _tooltip.translatesAutoresizingMaskIntoConstraints = NO;
    _tooltip.backgroundColor = [UIColor redColor];
    _tooltip.arrowPosOptions = FLTooltipArrowPosLeft;
    _tooltipIndent = kDefaultTooltipIndent;
    _tooltip.messageLabel.textColor = [UIColor whiteColor];
    _tooltip.messageLabel.font = [UIFont boldSystemFontOfSize:14];
    
    [[self.inputControl superview] addSubview:_tooltip];
    
    self.tooltipPos = FLValidatorTooltipPosBelow | FLValidatorTooltipPosRight;
    _tooltip.hidden = YES;
    
    // set permanent horizontal border constraints
    [[self.inputControl superview] addConstraint:[NSLayoutConstraint constraintWithItem:_tooltip
                                                                              attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                 toItem:_inputControl
                                                                              attribute:NSLayoutAttributeWidth
                                                                             multiplier:1
                                                                               constant:0]];
}

#pragma mark - Accessors

- (void)setTooltipMessage:(NSString *)message {
    _tooltip.message = message;
    _tooltipMessage = message;
}

- (void)setTooltipPos:(FLValidatorTooltipPos)pos {
    
    if (pos & FLValidatorTooltipPosAbove) {
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosTop;
        _tooltip.arrowPosOptions |= FLTooltipArrowPosBottom;
    }
    else if (pos & FLValidatorTooltipPosBelow) {
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosBottom;
        _tooltip.arrowPosOptions |= FLTooltipArrowPosTop;
    }
    
    if (pos & FLValidatorTooltipPosLeft) {
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosCenter;
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosRight;
        _tooltip.arrowPosOptions |= FLTooltipArrowPosLeft;
    }
    else if (pos & FLValidatorTooltipPosCenter) {
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosLeft;
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosRight;
        _tooltip.arrowPosOptions |= FLTooltipArrowPosCenter;
    }
    else if (pos & FLValidatorTooltipPosRight) {
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosLeft;
        _tooltip.arrowPosOptions &= ~FLTooltipArrowPosCenter;
        _tooltip.arrowPosOptions |= FLTooltipArrowPosRight;
    }
    
    _tooltipPos = pos;
    [self updateConstraints];
}

- (void)addValider:(FLValider *)valider {
    [_validers addObject:valider];
}

#pragma mark - Live circle

- (void)defineProperEvents {
    
    // this helper code shold be removed in future and the notication should be strongly predefined in during initialization
    if (!_changeNotificationName) {
        if ([_inputControl isKindOfClass:UIControl.class]) {
            _changeNotificationName = UITextFieldTextDidChangeNotification;
        }
        else if ([_inputControl isKindOfClass:UITextView.class]) {
            _changeNotificationName = UITextViewTextDidChangeNotification;
        }
        else if ([_inputControl isKindOfClass:FLDropDown.class]) {
            _changeNotificationName = FLDropDownDidChangedNotification;
        }
    }
        
    if (_changeNotificationName) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputControlDidChange:)
                                                     name:_changeNotificationName
                                                   object:nil];
    }
}

-(void)removeAppropriateEvents {
    if (_changeNotificationName) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:_changeNotificationName
                                                      object:nil];
    }
}

- (void)updateConstraints {
    if (_tooltip) {
        
        [[self.inputControl superview] removeConstraint:_horizontalConstrant];
        _horizontalConstrant = [NSLayoutConstraint constraintWithItem:_tooltip
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_inputControl
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1
                                                             constant:0];
        
        
        if (_tooltipPos & FLValidatorTooltipPosCenter) {
            _horizontalConstrant = [NSLayoutConstraint constraintWithItem:_tooltip
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_inputControl
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1
                                                                 constant:0];
        }
        else if (_tooltipPos & FLValidatorTooltipPosRight) {
            _horizontalConstrant = [NSLayoutConstraint constraintWithItem:_tooltip
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_inputControl
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1
                                                                 constant:0];
        }
        
        [[self.inputControl superview] addConstraint:_horizontalConstrant];
        
        
        [[self.inputControl superview] removeConstraint:_verticalContsraint];
        _verticalContsraint = [NSLayoutConstraint constraintWithItem:_tooltip
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_inputControl
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1
                                                            constant:_tooltipIndent];
        if (_tooltipPos & FLValidatorTooltipPosAbove) {
            _verticalContsraint = [NSLayoutConstraint constraintWithItem:_tooltip
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_inputControl
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:-_tooltipIndent];
        }
        
        [[self.inputControl superview] addConstraint:_verticalContsraint];
    }
}

- (void)validate {
    for (FLValider *valider in _validers) {
        if (_autoValidation && !valider.isAutoValidated) {
            continue;
        }
        if (![valider validate:_inputControl]) {
            _actualValider = valider;
            _isValid = NO;
            return;
        }
    }
    _isValid = YES;
}

#pragma mark - Events handlers

- (void)inputControlDidChange:(NSNotification *)notification {
    if (notification.object == _inputControl) {
        _autoValidation = YES;
        [self validate];

        if (kValidationTooltipDelay == 0) {
            [self inputValidation];
        } else {
            if (!_tooltip.hidden) {
                [self hideTooltip];
            }

            SEL aSelector = @selector(inputValidation);
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:aSelector object:nil];
            [self performSelector:aSelector withObject:nil afterDelay:1.0f];
        }
    }
}

- (void)inputValidation {
    [self manageTooltipMessage];
    _autoValidation = NO;
}

#pragma mark - Appearance

- (void)manageTooltipMessage {
    if (_autoValidation && !_actualValider.IsAutoHinted) {
        if (!self.tooltip.hidden) {
            [self hideTooltip];
        }
        return;
    }
    
    if (_isValid && !_tooltip.hidden) {
        [self hideTooltip];
    }
    else if (!_isValid && !_tooltip.hidden) {
        self.tooltipMessage = _actualValider.hint;
        [self.tooltip fadeOutWithDuration:kDefaultTooltipAnimationDuration delay:3.0f completion:nil];
    }
    else if (!_isValid) {
        self.tooltipMessage = _actualValider.hint;
        [self showHideTooltipInDelay:3.0f];
    }
}

- (void)showTooltip {
    CGRect originalFrame  = _tooltip.frame;
    [self moveToolip:YES];
    [_tooltip fadeInWithDuration:kDefaultTooltipAnimationDuration completion:nil];
    [UIView animateWithDuration:kDefaultTooltipAnimationDuration animations:^{
        _tooltip.frame = originalFrame;
    }];
}

- (void)showHideTooltipInDelay:(CGFloat)delay {
    [self showTooltip];
    [self.tooltip fadeOutWithDuration:kDefaultTooltipAnimationDuration delay:delay completion:nil];
}

- (void)hideTooltip {
    [_tooltip fadeOutWithDuration:kDefaultTooltipAnimationDuration completion:nil];
    [UIView animateWithDuration:kDefaultTooltipAnimationDuration
                     animations:^{
                         [self moveToolip:YES];
                     }
                     completion:^(BOOL finished){
                         [self moveToolip:NO];
                     }];
}

-(void)moveToolip:(BOOL)back {
    CGRect animationFrame = _tooltip.frame;
    CGFloat moveY = (_tooltipPos ==  FLValidatorTooltipPosAbove ? _tooltipIndent : - _tooltipIndent) * 2;
    animationFrame.origin.y +=  back ? moveY : -moveY;
    _tooltip.frame = animationFrame;
}

#pragma mark - Delloc

- (void)dealloc {
    [self removeAppropriateEvents];
}

@end
