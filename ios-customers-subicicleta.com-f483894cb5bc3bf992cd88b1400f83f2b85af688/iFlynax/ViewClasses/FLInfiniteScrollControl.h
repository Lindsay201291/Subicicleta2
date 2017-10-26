//
//  FLTableISContolView.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLInfiniteScrollControlDelegate.h"

typedef NS_ENUM(NSInteger, FLLoadingStackType) {
    FLLoadingStackTypeNext,
    FLLoadingStackTypeLast
};

@interface FLInfiniteScrollControl : UICollectionReusableView

@property (nonatomic, assign) id <FLInfiniteScrollControlDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *spinnerTextLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerAIView;
@property (weak, nonatomic) IBOutlet UIView *spinnerControlView;
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;

@property (nonatomic) BOOL infiniteScroll;
@property (nonatomic) NSString *autoLoadMessage;
@property (nonatomic) NSString *manualLoadMessage;
@property (nonatomic) NSString *manualLoadingMessage;
@property (nonatomic) BOOL loading;

+ (instancetype)initWithRect:(CGRect)rect;

- (void)defineMessagesWithStackType:(FLLoadingStackType)type withLoadAmount:(NSInteger)amount withTargetName:(NSString *)target;
- (void)defineMessagesWithTotal:(NSInteger)total withCurrentAmount:(NSInteger)amount withBatch:(NSInteger)batch withTarget:(NSString *)target;

@end
