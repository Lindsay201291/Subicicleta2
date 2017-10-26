//
//  FLPlansCollectionViewCell.m
//  iFlynax
//
//  Created by Alex on 2/26/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLRadioButton.h"

@class FLPlanModel;

@interface FLPlansCollectionViewCell : UICollectionViewCell
@property (nonatomic, assign) id<FLRadioButtonDelegate> radioButtonDelegate;

/**
 *	Description
 *	@param planInfo planInfo description
 */
- (void)withPlanInfo:(FLPlanModel *)planInfo;
@end
