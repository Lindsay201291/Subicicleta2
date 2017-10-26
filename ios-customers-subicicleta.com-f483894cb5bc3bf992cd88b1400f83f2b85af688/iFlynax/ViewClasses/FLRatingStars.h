//
//  FLRatingStars.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 8/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLRatingStars : UIView

@property (nonatomic) CGFloat rating;
@property (nonatomic) CGFloat starsSpacing;
@property (nonatomic) CGFloat starAnglesNumber;
@property (nonatomic) CGFloat starDepth;
@property (nonatomic) NSInteger starsNumber;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, copy) NSArray *gradientCGColors;

@end
