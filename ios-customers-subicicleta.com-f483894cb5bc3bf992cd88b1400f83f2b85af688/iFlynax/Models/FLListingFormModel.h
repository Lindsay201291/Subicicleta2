//
//  FLListingForm.h
//  iFlynax
//
//  Created by Alex on 2/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingTypeModel.h"
#import "FLCategoryModel.h"
#import "FLFieldModel.h"
#import "FLPlanModel.h"

@interface FLListingFormModel : NSObject
@property (nonatomic, assign) NSInteger          listingId;

@property (nonatomic, strong) FLListingTypeModel *listingType;
@property (nonatomic, strong) FLCategoryModel    *category;
@property (nonatomic, strong) FLCategoryModel    *savedCategory;

@property (nonatomic, strong) NSMutableArray     *categoriesForm;
@property (nonatomic, strong) NSMutableArray     *categoriesCache;
@property (nonatomic, strong) NSMutableArray     *removedPhotoIDs;

@property (nonatomic, strong) NSArray            *fields;
@property (nonatomic, strong) NSArray            *categoriesIDs;

@property (nonatomic, strong) FLPlanModel        *plan;

@property (nonatomic, strong) NSArray            *photos;
@property (nonatomic, strong) NSArray            *videos;

@property (nonatomic, copy  ) NSString           *langCode;

/**
 *	Description
 *	@return return value description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 */
- (void)resetForm;
@end
