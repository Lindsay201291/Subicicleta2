//
//  FLListingTypes.m
//  iFlynax
//
//  Created by Alex on 10/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLListingTypes.h"

static NSString * const kPositionKey = @"position";

@interface FLListingTypes () {
    NSInteger _typesCount;
    FLListingTypeModel *_mainType;
}
@end

@implementation FLListingTypes

+ (instancetype)sharedInstance {
	static FLListingTypes *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	return _sharedInstance;
}

+ (id)withKey:(NSString *)key {
	return [[FLListingTypes sharedInstance] withKey:key asModel:NO];
}

+ (FLListingTypeModel *)withKeyAsModel:(NSString *)key {
    return [[FLListingTypes sharedInstance] withKey:key asModel:YES];
}

+ (NSArray *)getList {
	return [[FLListingTypes sharedInstance] getList];
}

+ (NSInteger)typesCount {
    return [[FLListingTypes sharedInstance] typesCount];
}

#pragma mark -

- (NSArray *)getList {
    static NSArray *lTypes;
    lTypes = [[[NSUserDefaults standardUserDefaults] objectForKey:kCacheListingTypesKey] allValues];

    NSArray *sortedValues = [lTypes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int pos1 = [obj1[kPositionKey] intValue];
        int pos2 = [obj2[kPositionKey] intValue];

        if (pos1 < pos2) return NSOrderedAscending;
        else if (pos1 > pos2) return NSOrderedDescending;
        return NSOrderedSame;
    }];
	return sortedValues;
}

- (FLListingTypeModel *)mainType {
    NSDictionary *firstType = [[self getList] firstObject];
    _mainType = [FLListingTypeModel fromDictionary:firstType];

    return _mainType;
}

- (NSInteger)typesCount {
    if (!_typesCount) {
        _typesCount = [self getList].count;
    }
    return _typesCount;
}

- (id)withKey:(NSString *)key asModel:(BOOL)model {
	NSArray *lTypes = [self getList];
    __block id listingType = nil;

    if (!_typesCount) {
        _typesCount = lTypes.count;
    }

    [lTypes enumerateObjectsUsingBlock:^(NSDictionary *type, NSUInteger idx, BOOL *stop) {
        if ([type[@"key"] isEqualToString:key]) {
            if (model) listingType = [FLListingTypeModel fromDictionary:type];
            else listingType = type;
            *stop = YES;
        }
    }];
	return listingType;
}

#pragma mark -

- (NSArray *)buildBrowseMenuSection {
	NSArray *staticTitles = @[@{@"name": FLLocalizedString(@"menu_recently_added"),   @"icon": @"menu_recently_added"},
							  @{@"name": FLLocalizedString(@"menu_search_around_me"), @"icon": @"menu_search_around_me"},
                              @{@"name": FLLocalizedString(@"menu_search"), @"icon": @"menu_search"}];
	NSMutableArray *sectionRows = [NSMutableArray arrayWithArray:staticTitles];
    NSArray *lTypes = [self getList];

    if (!_typesCount) {
        _typesCount = lTypes.count;
    }

    [lTypes enumerateObjectsUsingBlock:^(NSDictionary *type, NSUInteger idx, BOOL *stop) {
        FLListingTypeModel *model = [FLListingTypeModel fromDictionary:type];
        [sectionRows addObject:model];
    }];

	return sectionRows;
}

@end
