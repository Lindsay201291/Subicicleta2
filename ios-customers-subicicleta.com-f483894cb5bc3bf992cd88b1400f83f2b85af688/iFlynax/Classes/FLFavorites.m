//
//  FLFavorites.m
//  iFlynax
//
//  Created by Alex on 11/10/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLFavorites.h"

static NSString * const kFavoritesGlobalKey = @"favoritesGlobal";
static NSString * const kUpdateActionAdd    = @"add";
static NSString * const kUpdateActionRemove = @"remove";

@interface FLFavorites () {
    NSInteger _favItemsCount;
}
@property (nonatomic, strong) NSMutableDictionary *favoriteAds;
@end

@implementation FLFavorites

+ (instancetype)sharedInstance {
	static FLFavorites *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];

		// put favorites from user defaults
		NSDictionary *favoriteAds = [[NSUserDefaults standardUserDefaults] objectForKey:kFavoritesGlobalKey];
        if (favoriteAds == nil) {
            favoriteAds = @{};
        }
		_sharedInstance.favoriteAds = [favoriteAds mutableCopy];
	});
	return _sharedInstance;
}

- (void)addToFavorites:(NSInteger)adId {
    [self addToFavorites:adId updateAPI:YES];
}

- (void)addToFavorites:(NSInteger)adId updateAPI:(BOOL)update {
	[_favoriteAds setValue:@(adId) forKey:[self adIdToKey:adId]];
    _favItemsCount++;

    if (update) {
        [self saveToDefaults];
        [self updateFavoritesOnAPI:adId action:kUpdateActionAdd];
    }
}

- (void)removeFromFavorites:(NSInteger)adId {
    [self removeFromFavorites:adId updateAPI:YES]; 
}

- (void)removeFromFavorites:(NSInteger)adId updateAPI:(BOOL)update {
	[_favoriteAds setValue:nil forKey:[self adIdToKey:adId]];
    _favItemsCount--;

	[self saveToDefaults];
    [self updateFavoritesOnAPI:adId action:kUpdateActionRemove];
}

- (void)updateFavoritesOnAPI:(NSInteger)lid action:(NSString *)action {
    if (IS_LOGIN) {
        [flynaxAPIClient postApiItem:kApiItemFavorites
                          parameters:@{@"action": action,
                                       @"lid"   : @(lid)}
                          completion:nil];
    }
}

- (void)saveToDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_favoriteAds forKey:kFavoritesGlobalKey];
	[defaults synchronize];
}

- (void)clearFavorites {
    [_favoriteAds removeAllObjects];
    _favItemsCount = 0;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:_favoriteAds forKey:kFavoritesGlobalKey];
    [defaults synchronize];
}

+ (NSInteger)itemsCount {
    return [[FLFavorites sharedInstance] itemsCount];
}

- (NSInteger)itemsCount {
    if (!_favItemsCount) {
        _favItemsCount = _favoriteAds.count;
    }
    return MAX(_favItemsCount, 0);
}

- (void)updateItemsCount:(NSInteger)count {
    _favItemsCount = count;
}

#pragma mark - Helpers

- (BOOL)isFavoriteWithId:(NSInteger)adId {
	NSString *fKey = [self adIdToKey:adId];
	return (_favoriteAds[fKey] != nil) ?: NO;
}

- (NSString *)adIdToKey:(NSInteger)adId {
	return F(@"lid_%d", (int)adId);
}

+ (NSString *)allFavoritesAsString {
    NSArray *ids = [[FLFavorites sharedInstance].favoriteAds allValues];
    return [ids componentsJoinedByString:@","];
}

+ (NSDictionary *)allItems {
	return [FLFavorites sharedInstance].favoriteAds;
}

+ (void)synchronizeFavorites:(NSString *)stringIds {
    if (FLCleanString(stringIds).length) {
        [[FLFavorites sharedInstance].favoriteAds removeAllObjects];

        NSArray *ids = [stringIds componentsSeparatedByString:@","];
        [ids enumerateObjectsUsingBlock:^(NSString *lid, NSUInteger idx, BOOL * _Nonnull stop) {
            [[FLFavorites sharedInstance] addToFavorites:[lid integerValue] updateAPI:NO];
        }];
        [[FLFavorites sharedInstance] saveToDefaults];
    }
}

@end
