//
//  FLAccountTypes.m
//  iFlynax
//
//  Created by Alex on 10/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAccountTypes.h"

static NSString * const kPositionKey = @"position";

@interface FLAccountTypes () {
    NSInteger _typesCount;
}
@end

@implementation FLAccountTypes

+ (instancetype)sharedInstance {
	static FLAccountTypes *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	return _sharedInstance;
}

+ (id)withKey:(NSString *)key {
	return [[FLAccountTypes sharedInstance] withKey:key asModel:NO];
}

+ (FLAccountTypeModel *)withKeyAsModel:(NSString *)key {
    return [[FLAccountTypes sharedInstance] withKey:key asModel:YES];
}

+ (NSArray *)getList {
	return [[FLAccountTypes sharedInstance] getList];
}

+ (NSInteger)typesCount {
    return [[FLAccountTypes sharedInstance] typesCount];
}

#pragma mark - Common

- (NSArray *)getList {
    static NSArray *aTypes;
    aTypes = [[[NSUserDefaults standardUserDefaults] objectForKey:kCacheAccountTypesKey] allValues];

    NSArray *sortedValues = [aTypes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int pos1 = [obj1[kPositionKey] intValue];
        int pos2 = [obj2[kPositionKey] intValue];

        if (pos1 < pos2) return NSOrderedAscending;
        else if (pos1 > pos2) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    return sortedValues;
}

- (NSInteger)typesCount {
    if (!_typesCount) {
        _typesCount = [self getList].count;
    }
    return _typesCount;
}

- (id)withKey:(NSString *)key asModel:(BOOL)model {
	NSArray *aTypes = [self getList];
    __block id accountType = nil;

    if (!_typesCount) {
        _typesCount = aTypes.count;
    }

    [aTypes enumerateObjectsUsingBlock:^(NSDictionary *type, NSUInteger idx, BOOL *stop) {
        if ([type[@"key"] isEqualToString:key]) {
            if (model) accountType = [FLListingTypeModel fromDictionary:type];
            else accountType = type;
            *stop = YES;
        }
    }];
	return accountType;
}

#pragma mark - Swipe Menu

- (NSArray *)buildAccountTypesMenuSection {
    NSMutableArray *section = [NSMutableArray array];

    [[self getList] enumerateObjectsUsingBlock:^(NSDictionary *type, NSUInteger idx, BOOL *stop) {
        FLAccountTypeModel *accountType = [FLAccountTypeModel fromDictionary:type];
        if (accountType.page) {
            [section addObject:accountType];
        }
    }];

	return section;
}

#pragma mark - FLFieldModel

- (FLFieldModel *)buildValuesAsSelectField {
    FLFieldModel *model = [FLFieldModel fromDictionary:@{@"name"  : FLLocalizedString(@"dropdown_title_account_types"),
                                                         @"key"   : @"atype",
                                                         @"type"  : @"select",
                                                         @"values": [self getList]}];
    return model;
}

@end
