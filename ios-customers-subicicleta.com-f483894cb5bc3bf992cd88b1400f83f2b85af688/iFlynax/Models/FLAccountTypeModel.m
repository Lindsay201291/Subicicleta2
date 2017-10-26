//
//  FLAccountTypeModel.m
//  iFlynax
//
//  Created by Alex on 3/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAccountTypeModel.h"

@implementation FLAccountTypeModel

+ (instancetype)fromDictionary:(NSDictionary *)accountType {
    return [[FLAccountTypeModel alloc] initFromDictionary:accountType];
}

- (instancetype)initFromDictionary:(NSDictionary *)accountType {
    self = [super init];
    if (self) {
        _key          = FLCleanString(accountType[@"key"]);
        _name         = FLCleanString(accountType[@"name"]);
        _autoLogin    = FLTrueBool(accountType[@"autoLogin"]);
        _emailConfirm = FLTrueBool(accountType[@"emailConfirmation"]);
        _ownLocation  = FLTrueBool(accountType[@"ownLocation"]);
        _page         = FLTrueBool(accountType[@"page"]);
        _searchForm   = (_page && self.searchFormFields.count);
    }
    return self;
}

- (NSArray *)searchFormFields {
    if (!_searchFormFields) {
        NSDictionary *_forms;
        _forms = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheAccountSearchFormsKey];

        if (!_forms || ![_forms isKindOfClass:NSDictionary.class]) {
            return @[];
        }
        _searchFormFields = (_forms[_key] != nil) ? _forms[_key] : @[];
    }
    return _searchFormFields;
}

@end
