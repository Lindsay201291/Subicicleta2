//
//  FLManageCategory.h
//  iFlynax
//
//  Created by Alex on 3/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kPlanTitleColorNormal = @"000000";

typedef NS_ENUM(NSInteger, FLCategoryBoxBtn) {
    FLCategoryBoxBtnEdit       = 1,
    FLCategoryBoxBtnSelectPlan = 2
};

@class FLCategoryBox;

@protocol FLCategoryBoxDelegate <NSObject>
- (void)categoryBox:(FLCategoryBox *)box buttonTapped:(FLCategoryBoxBtn)button;
@end

@interface FLCategoryBox : UIView
@property (strong, nonatomic) id <FLCategoryBoxDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *breadcrumbs;
@property (strong, nonatomic) NSString       *planTitleColor;
@property (copy, nonatomic  ) NSString       *planTitle;
@property (assign, nonatomic) BOOL           planBtnActive;
@property (assign, nonatomic) BOOL           editCategoryBtnActive;

/**
 *	Description
 */
- (void)buildBreadcrumbs;

- (void)removePlanBoxFromSuperview;
@end
