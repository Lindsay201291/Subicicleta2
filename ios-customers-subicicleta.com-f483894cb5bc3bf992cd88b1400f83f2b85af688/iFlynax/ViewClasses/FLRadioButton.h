//
//  FLRadioButton.h
//  iFlynax
//
//  Created by Alex on 7/7/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "DLRadioButton.h"

@class FLRadioButton;

@protocol FLRadioButtonDelegate <NSObject>
@optional

/**
 *	Description
 *	@param button button description
 */
- (void)FLRadioButtonDidTapped:(FLRadioButton *)button;
@end

@interface FLRadioButton : DLRadioButton
@property (nonatomic, assign) id<FLRadioButtonDelegate> delegate;
@property (nonatomic, strong) id userInfo;

+ (instancetype)withFrame:(CGRect)frame;

/**
 *	Description
 *	@param frame frame description
 *	@param title title description
 */
- (instancetype)initWithFrame:(CGRect)frame buttonTitle:(NSString *)title;
@end
