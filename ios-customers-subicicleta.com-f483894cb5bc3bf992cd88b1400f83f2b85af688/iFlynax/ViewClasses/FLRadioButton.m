//
//  FLRadioButton.m
//  iFlynax
//
//  Created by Alex on 7/7/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLRadioButton.h"

static CGFloat const kRadioButtonIconSize    = 22;
static CGFloat const kRadioButtonMarginWidth = 8;

@implementation FLRadioButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

+ (instancetype)withFrame:(CGRect)frame {
    FLRadioButton *button = [[FLRadioButton alloc] initWithFrame:frame];
    [button setup];
    return button;
}

- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:title forState:UIControlStateNormal];
        [self setup];
    }
    return self;
}

- (void)setup {
    UIControlContentHorizontalAlignment _aligment = UIControlContentHorizontalAlignmentLeft;
    CGFloat marginBetweenTitleAndIcon = kRadioButtonMarginWidth;

    if (IS_RTL) {
        self.iconOnRight = YES;
        marginBetweenTitleAndIcon = -(kRadioButtonIconSize - kRadioButtonMarginWidth);
        _aligment = UIControlContentHorizontalAlignmentRight;
    }

    [self setContentHorizontalAlignment:_aligment];
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

    self.indicatorColor  = [UIColor hexColor:kColorRadioButtonIndicatorColor];
    self.marginWidth     = marginBetweenTitleAndIcon;
    self.iconSize        = kRadioButtonIconSize;
    self.indicatorSize   = 12;
    self.iconStrokeWidth = 1;
}

- (void)setDelegate:(id<FLRadioButtonDelegate>)delegate {
    _delegate = delegate;

    if (_delegate != nil && [delegate respondsToSelector:@selector(FLRadioButtonDidTapped:)]) {
        [self addTarget:_delegate action:@selector(FLRadioButtonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
