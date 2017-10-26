//
//  FLPlansManager.h
//  iFlynax
//
//  Created by Alex on 11/3/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLPlanModel.h"

@interface FLPlansManager : NSObject
@property (nonatomic, strong) NSMutableArray *plans;
@property (nonatomic, strong) NSMutableArray *planButtons;
@property (nonatomic, strong) FLPlanModel    *selectedPlan;
@property (nonatomic, strong) FLPlanModel    *currentPlan;
@property (nonatomic, assign) BOOL           planWasChanged;

@property (nonatomic, strong) NSMutableDictionary *skProducts;

+ (instancetype)sharedManager;
+ (void)restoreToDefaults;
@end
