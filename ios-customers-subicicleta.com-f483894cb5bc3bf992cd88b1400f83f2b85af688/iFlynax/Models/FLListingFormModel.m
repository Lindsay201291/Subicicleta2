//
//  FLListingForm.m
//  iFlynax
//
//  Created by Alex on 2/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingFormModel.h"

@implementation FLListingFormModel

+ (instancetype)sharedInstance {
    static FLListingFormModel *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetForm];
    }
    return self;
}

- (void)resetForm {
    _fields          = @[];
    _photos          = @[];
    _videos          = @[];
    _categoriesIDs   = @[];

    _categoriesForm  = [NSMutableArray array];
    _categoriesCache = [NSMutableArray array];
    _removedPhotoIDs = [NSMutableArray array];

    _listingType     = nil;
    _plan            = nil;

    _langCode        = [FLLang langCode];
}

- (void)setCategoriesIDs:(NSArray *)categoriesIDs {
    if (categoriesIDs.count) {
        NSMutableArray *integerIDs = [NSMutableArray array];

        for (id cid in categoriesIDs) {
            [integerIDs addObject:@(FLTrueInteger(cid))];
        }
        _categoriesIDs = integerIDs;
    }
}

@end
