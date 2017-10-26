//
//  FLPlanOptionsView.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 7/15/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLPlanOptionsView.h"
#import "FLPlansManager.h"

@interface FLPlanOptionsView () {
    CGFloat _aHeight, _vSpacing;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end


@implementation FLPlanOptionsView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _vSpacing = 5.0f;
        _aHeight  = 0;
    }
    return self;
}


-(void)addView:(UIView *)view {
   
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:view];
    
    
    //add proper constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:_aHeight]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0f
                                                      constant:0]];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:view.height]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0f
                                                      constant:0]];
    
    _aHeight += view.height + _vSpacing;
    
}

- (void)updateConstraints {
    [super updateConstraints];
    
    
    if (_aHeight)
        _heightConstraint.constant = _aHeight - _vSpacing;
    
}

- (void)clear {
    _vSpacing = 5.0f;
    _aHeight  = 0;

    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
        [[FLPlansManager sharedManager].planButtons removeObject:subview];
    }
}

@end
