//
//  FLCategoryModel.h
//  iFlynax
//
//  Created by Alex on 2/25/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLCategoryModel : NSObject
@property (nonatomic, assign, readonly) NSInteger cId;
@property (nonatomic, assign, readonly) NSInteger level;
@property (nonatomic, assign, readonly) NSInteger adsCount;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSString *path;
@property (nonatomic, assign, readonly) BOOL locked;

@property (nonatomic, assign          ) BOOL children;
@property (nonatomic, strong          ) NSArray *subCategories;

/**
 *	Convert category from dictionary to model
 *	@param category - dictionary of category
 *	@return model of category
 */
+ (instancetype)fromDictionary:(NSDictionary *)category;
@end
