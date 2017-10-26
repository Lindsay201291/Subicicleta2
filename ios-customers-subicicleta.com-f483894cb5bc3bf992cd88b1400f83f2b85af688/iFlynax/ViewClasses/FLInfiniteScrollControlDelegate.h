//
//  FLInfiniteScrollControlDelegate.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLInfiniteScrollControl.h"

@class FLInfiniteScrollControl;

@protocol FLInfiniteScrollControlDelegate <NSObject>

- (void)flInfiniteScrollControl:(FLInfiniteScrollControl *)control loadMoreButtonTaped:(UIButton *)button;

@optional

- (void)flInfiniteScrollControl:(FLInfiniteScrollControl *)control hasScrolledOut:(UIScrollView *)scrollView;

@end
