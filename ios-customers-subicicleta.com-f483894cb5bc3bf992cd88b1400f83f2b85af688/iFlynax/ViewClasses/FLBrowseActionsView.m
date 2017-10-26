//
//  FLBrowseActionsView.m
//  iFlynax
//
//  Created by Alex on 5/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLBrowseActionsView.h"

@interface UIButton (ModifySize)
- (void)updatePosition:(CGPoint)position;
@end

@implementation UIButton (ModifySize)
- (void)updatePosition:(CGPoint)position {
    CGRect frame = self.frame;
    frame.origin = position;
    self.frame = frame;
}
@end


/////////////

static CGFloat const kBtnWidth   = 30.0f;
static CGFloat const kBtnHeight  = 30.0f;
static CGFloat const kBtnPadding = 15.0f;

@interface FLBrowseActionsView ()
@property (strong, nonatomic) UIButton *sortingBtn;
@property (strong, nonatomic) UIButton *subCategoriesBtn;
@end

@implementation FLBrowseActionsView

#pragma mark - Getters

- (UIButton *)sortingBtn {
    if (_sortingBtn == nil) {
        _sortingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sortingBtn setBackgroundImage:[UIImage imageNamed:@"sorting"] forState:UIControlStateNormal];
        [_sortingBtn setFrame:CGRectMake(0, 0, kBtnWidth, kBtnHeight)];
        [_sortingBtn setTag:FLBrowseActionsBtnSorting];
        [_sortingBtn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sortingBtn;
}

- (UIButton *)subCategoriesBtn {
    if (_subCategoriesBtn == nil) {
        _subCategoriesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subCategoriesBtn setBackgroundImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        [_subCategoriesBtn setFrame:CGRectMake(kBtnWidth + kBtnPadding, 0, kBtnWidth, kBtnHeight)];
        [_subCategoriesBtn setTag:FLBrowseActionsBtnSubCategories];
        [_subCategoriesBtn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subCategoriesBtn;
}

#pragma mark -

- (void)btnTapped:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionsViewButtonTapped:)]) {
        [self.delegate actionsViewButtonTapped:button.tag];
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.sorting) {
        if (!self.subCategories) {
            [self.sortingBtn updatePosition:(CGPoint){kBtnWidth + kBtnPadding, 0}];
        }
        [self addSubview:self.sortingBtn];
    }
    else {
        [self.sortingBtn removeFromSuperview];
    }

    if (self.subCategories) {
        [self addSubview:self.subCategoriesBtn];
    }
    else {
        [self.subCategoriesBtn removeFromSuperview];

        if (IS_RTL && self.sorting) {
            [self.sortingBtn updatePosition:(CGPoint){0, 0}];
        }
    }
}

@end
