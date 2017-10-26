//
//  FLListingType.h
//  iFlynax
//
//  Created by Alex on 2/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLListingTypeModel : NSObject
@property (nonatomic, strong, readonly) NSString  *icon;
@property (nonatomic, strong, readonly) NSString  *key;
@property (nonatomic, strong, readonly) NSString  *name;
@property (nonatomic, assign, readonly) NSInteger position;
@property (nonatomic, assign, readonly) BOOL      page;
@property (nonatomic, assign, readonly) BOOL      photo;
@property (nonatomic, assign, readonly) BOOL      search;
@property (nonatomic, assign, readonly) BOOL      video;

@property (nonatomic, copy, readonly) NSString *categoriesSortBy;

/**
 *	Convert listing type from dictionary to model
 *	@param listingType - dictionary of listing type
 *	@return model of listing type
 */
+ (instancetype)fromDictionary:(NSDictionary *)listingType;
@end
