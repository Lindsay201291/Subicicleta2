//
//  FLFavorites.h
//  iFlynax
//
//  Created by Alex on 11/10/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLFavorites : NSObject

/**
 *	Description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 *	@param adId adId description
 */
- (void)addToFavorites:(NSInteger)adId;
- (void)addToFavorites:(NSInteger)adId updateAPI:(BOOL)update;

/**
 *	Description
 *	@param adId adId description
 */
- (void)removeFromFavorites:(NSInteger)adId;
- (void)removeFromFavorites:(NSInteger)adId updateAPI:(BOOL)update;

/**
 *	Description
 */
- (BOOL)isFavoriteWithId:(NSInteger)adId;

- (void)updateItemsCount:(NSInteger)count;

/**
 *	Description
 *	@return return value description
 */
+ (NSDictionary *)allItems;

/**
 *	Description
 *	@return return value description
 */
+ (NSString *)allFavoritesAsString;

+ (NSInteger)itemsCount;

/**
 *	Description
 *	@param stringIds description
 */
+ (void)synchronizeFavorites:(NSString *)stringIds;

- (void)clearFavorites;
@end
