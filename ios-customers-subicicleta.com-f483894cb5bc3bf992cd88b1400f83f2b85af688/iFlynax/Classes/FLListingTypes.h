//
//  FLListingTypes.h
//  iFlynax
//
//  Created by Alex on 10/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLListingTypeModel.h"

@interface FLListingTypes : NSObject

/**
 *	Description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 *	@param key key description
 *	@return return value description
 */
+ (id)withKey:(NSString *)key;

/**
 *	Description
 *	@param key key description
 *	@return return value description
 */
+ (FLListingTypeModel *)withKeyAsModel:(NSString *)key;

/**
 *	Description
 *	@return return value description
 */
+ (NSArray *)getList;

/**
 *	Description
 *	@return return value description
 */
+ (NSInteger)typesCount;

/**
 *	Description
 *	@return return value description
 */
- (FLListingTypeModel *)mainType;

/**
 *	Description
 *	@return return value description
 */
- (NSArray *)buildBrowseMenuSection;
@end
