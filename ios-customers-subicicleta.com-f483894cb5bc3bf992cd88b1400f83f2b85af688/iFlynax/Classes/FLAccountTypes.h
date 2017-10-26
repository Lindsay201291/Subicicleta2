//
//  FLAccountTypes.h
//  iFlynax
//
//  Created by Alex on 10/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAccountTypeModel.h"
#import "FLFieldModel.h"

@interface FLAccountTypes : NSObject

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
+ (FLAccountTypeModel *)withKeyAsModel:(NSString *)key;

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
- (NSArray *)buildAccountTypesMenuSection;

- (FLFieldModel *)buildValuesAsSelectField;
@end
