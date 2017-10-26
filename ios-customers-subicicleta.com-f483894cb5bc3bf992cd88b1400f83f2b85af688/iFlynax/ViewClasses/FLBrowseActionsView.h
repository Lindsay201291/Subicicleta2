//
//  FLBrowseActionsView.h
//  iFlynax
//
//  Created by Alex on 5/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLBrowseActionsBtn) {
    FLBrowseActionsBtnSorting       = 1,
    FLBrowseActionsBtnSubCategories = 2,
    FLBrowseActionsBtnSearch        = 3
};

@protocol FLBrowseActionsViewDelegate <NSObject>
@optional
- (void)actionsViewButtonTapped:(FLBrowseActionsBtn)button;
@end

@interface FLBrowseActionsView : UIView
@property (strong, nonatomic) id <FLBrowseActionsViewDelegate> delegate;
@property (assign, nonatomic) BOOL sorting;
@property (assign, nonatomic) BOOL subCategories;
@end
