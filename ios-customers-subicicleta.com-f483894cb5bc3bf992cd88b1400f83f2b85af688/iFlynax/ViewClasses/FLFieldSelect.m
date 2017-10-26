//
//  FLFieldSelect.m
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldSelect.h"

static NSString * const kLevelPosfix = @"_level";

typedef void (^FLMFCompletionHandler)(NSArray *options);

@interface FLFieldSelect ()
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDictionary *userData;
@end

@implementation FLFieldSelect

+ (instancetype)fromModel:(FLFieldModel *)model tableView:(UITableView *)tableView userData:(NSDictionary *)data {
    return [[self alloc] fromModel:model tableView:tableView userData:data];
}

+ (instancetype)fromModel:(FLFieldModel *)model tableView:(UITableView *)tableView {
    return [[self alloc] fromModel:model tableView:tableView userData:nil];
}

+ (instancetype)withTitle:(NSString *)title options:(NSArray *)options {
    return [[self alloc] withTitle:title options:options];
}

#pragma mark - Private methods

- (void)setup {
    self.style        = UITableViewCellStyleValue1;
    self.valueChanged = YES;
    self.cellHeight   = 60;
    self.enabled      = YES;
    self.placeholder  = self.name;

    [self parseModelCurrent];

    // multiField implementation
    if (self.model.multiField) {
        self.actionBarDoneButtonTapHandler = ^(FLFieldSelect *item) {
            if (item.valueChanged) {
                [item loadNextMultiFieldLevelIfNecessary];
            }
        };
    }
    [self manageDefaultValue:NO];
}

- (instancetype)withTitle:(NSString *)title options:(NSArray *)options {
    if (self) {
        self.name    = title;
        self.options = options;
        [self setup];
    }
    return self;
}

- (instancetype)fromModel:(FLFieldModel *)model tableView:(UITableView *)tableView userData:(NSDictionary *)data {
    if (self) {
        self.model     = model;
        self.name      = model.name;
        self.options   = model.values;
        self.tableView = tableView;
        self.userData  = data;
        self.twoFields = (model.searchMode
                          && [model.key isEqualToString:FLConfigWithKey(@"year_build_key")]);

        [self setup];
    }
    return self;
}

#pragma mark - 

- (void)manageDefaultValue:(BOOL)afterReset {
    if ([self isValidDefaultValue]) {
        if (self.model.multiField) {
            NSArray *_components = [self.model.key componentsSeparatedByString:kLevelPosfix];
            int mf_level = _components.count == 1 ? 0 : FLTrueInt(_components.lastObject);

            if (mf_level == 0) {
                self.valueFrom = self.model.defaultValue;

                if (afterReset == YES) {
                    [self loadNextMultiFieldLevelIfNecessary];
                }
                // TODO: Probably it's a not good idea; look at mee later
                else {
                    NSTimeInterval delay = .3f;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self loadNextMultiFieldLevelIfNecessary];
                    });
                }
            } else if (mf_level == 1) {
                self.valueFrom = self.model.defaultValue;
                
                [self loadMFOptionsWithCompletion:^(NSArray *options) {
                    self.options = options;
                    self.valueFrom = nil;
                }];
            }
        } else {
            self.valueFrom = self.model.defaultValue;
        }
    }
}

- (BOOL)isValidDefaultValue {
    return (self.valueFrom == nil &&
            self.model.defaultValue != nil &&
            [self.model.defaultValue isKindOfClass:NSDictionary.class]);
}

- (void)parseModelCurrent {
    if (self.model &&
        self.model.current &&
        [self.model.current isKindOfClass:NSString.class] &&
        [self.model.current length])
    {
        for (NSDictionary *option in self.options) {
            if ([self.model.current isEqualToString:option[@"key"]]) {
                self.valueFrom = option;
                break;
            }
        }
    }
}

// @override value
- (id)value {
    if (self.twoFields) {
        return nil;
    }
    return _valueFrom;
}

- (NSDictionary *)itemData {
    if (self.model == nil) {
        return nil;
    }

    if (self.twoFields) {
        if (self.valueFrom == nil && self.valueTo == nil) {
            return nil;
        }
        return @{self.model.key : @{kItemFrom : FLTrueString(self.valueFrom[kItemKey]),
                                    kItemTo   : FLTrueString(self.valueTo[kItemKey])}};
    }

    if (self.valueFrom != nil) {
        NSString *fieldKey = self.model.key;

        if (self.model.multiField &&
            [self.model.key rangeOfString:kFieldCategoryIDKey].location != NSNotFound)
        {
            fieldKey = kFieldCategoryIDKey;
        }
        return @{fieldKey : FLTrueString(self.valueFrom[kItemKey])};
    }
    return nil;
}

- (void)resetValues {
    self.valueFrom = nil;
    self.valueTo = nil;
    self.value = nil;
    [self manageDefaultValue:YES];
}

- (BOOL)isValid {
    if (self.model.required && self.valueFrom == nil) {
        self.errorMessage = FLLocalizedString(@"valider_select_an_option");
        return NO;
    }
    return YES;
}

#pragma mark - MultiField

- (BOOL)isChildOfParent:(FLFieldSelect *)parent {
    if (!self.model || !self.model.multiField) {
        return NO;
    }

    /* prepare parent */
    NSArray *parentComponents = [parent.model.key componentsSeparatedByString:kLevelPosfix];
    NSString *parentKey = parentComponents[0];
    int parentLevel = (parentComponents.count == 1) ? 0 : FLTrueInt(parentComponents[1]);
    /* prepare parent end */

    /* prepare parent */
    NSArray *inferredChildComponents = [self.model.key componentsSeparatedByString:kLevelPosfix];
    NSString *inferredChildKey = inferredChildComponents[0];
    int inferredChildLevel = (inferredChildComponents.count == 1) ? 0 : FLTrueInt(inferredChildComponents[1]);
    /* prepare parent end */

    return ([parentKey isEqualToString:inferredChildKey] && inferredChildLevel > parentLevel);
}

- (void)loadNextMultiFieldLevelIfNecessary {
    BOOL _loading = NO;

    for (FLFieldSelect *item in self.section.items) {
        if ([item isKindOfClass:FLFieldSelect.class]) {
            if (item.model.multiField && [item isChildOfParent:self]) {
                if (!_loading && self.valueFrom != nil) {
                    item.loadingOptions = YES;

                    [self loadMFOptionsWithCompletion:^(NSArray *options) {
                        item.options = options;
                        item.loadingOptions = NO;
                        [self tableViewReloadDataAsync];
                    }];
                    _loading = YES;
                }
                item.valueFrom   = nil;
                item.options = @[];
            }
        }
    }
    [self tableViewReloadDataAsync];
}

- (void)loadMFOptionsWithCompletion:(FLMFCompletionHandler)completion {
    NSString *selectorValue = FLTrueString(self.valueFrom[@"key"]);
    NSDictionary *parameters = @{};

    if ([self.model.key rangeOfString:kFieldCategoryIDKey].location != NSNotFound) {
        parameters = @{@"cmd": kApiItemRequests_categories,
                       @"ltype_key"  : FLTrueString(self.userData[kFieldListingTypeKey]),
                       @"category_id": selectorValue,
                       @"mf_value"   : @(YES)};
    } else {
        parameters = @{@"cmd"   : kApiItemRequests_multifield,
                       @"parent": selectorValue};
    }

    [flynaxAPIClient getApiItem:kApiItemRequests
                     parameters:parameters
                     completion:^(NSArray *response, NSError *error) {
                         if (error == nil && [response isKindOfClass:NSArray.class]) {
                             if (completion != nil) {
                                 completion(response);
                             }
                         }
                         else [FLDebug showAdaptedError:error apiItem:parameters[@"cmd"]];
                     }];
}

- (void)tableViewReloadDataAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
