//
//  FLListingSelectPlan.h
//  iFlynax
//
//  Created by Alex on 2/26/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "FLPlanModel.h"

typedef void (^FLListingSelectPlanCompletion)(FLPlanModel *listingPlan);

@interface FLListingSelectPlan : FLViewController
@property (nonatomic, copy) FLListingSelectPlanCompletion completionBlock;
@property (nonatomic, assign) NSInteger selectPlanById;
@property (nonatomic, assign) NSInteger categoryId;

@property (nonatomic, assign) BOOL featuredPlansOnly;
@property (nonatomic, assign) BOOL upgradeMode;
@end
