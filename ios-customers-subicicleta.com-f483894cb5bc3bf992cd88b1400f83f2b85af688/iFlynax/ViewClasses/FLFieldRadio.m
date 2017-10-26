//
//  FLFieldRadio.m
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldRadio.h"

static NSString * const kFieldRadioKey          = @"key";
static NSString * const kFieldRadioSaleRent     = @"sale_rent";
static NSString * const kFieldRadioTimeFrame    = @"time_frame";
static NSString * const kFieldRadioWithPictures = @"ios_search_with_pictures";

@interface FLFieldRadio ()
@property (strong, nonatomic) UITableView  *tableView;
@property (strong, nonatomic) FLFieldRadio *timeFrameField;
@property (assign, nonatomic) NSUInteger   timeFrameIndex;
@end

@implementation FLFieldRadio

+ (instancetype)fromModel:(FLFieldModel *)model tableView:(UITableView *)tableView {
    return [[self alloc] initWithModel:model tableView:tableView];
}

- (instancetype)initWithModel:(FLFieldModel *)model tableView:(UITableView *)tableView {
    if (self) {
        self.model        = model;
        self.caption      = model.name;
        self.options      = model.values;
        self.enabled      = YES;
        self.tableView    = tableView;

        self.cellHeight   = (self.options && self.options.count
                             ? self.options.count * 40
                             : 60);

        _checkBoxMode = (self.model.searchMode
                         && [self.model.key isEqualToString:kFieldRadioWithPictures]);

        [self parseModelCurrent];

        if ([model.key isEqualToString:kFieldRadioSaleRent]) {
            __unsafe_unretained typeof(self) weakSelf = self;
            self.valueWasChanged = ^{
                if (weakSelf.timeFrameField) {
                    if (FLTrueInt(weakSelf.value) == 1) { // Sale
                        [weakSelf.section removeItemIdenticalTo:weakSelf.timeFrameField];
                    }
                    else { // Rent
                        [weakSelf.section insertItem:weakSelf.timeFrameField atIndex:weakSelf.timeFrameIndex];
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                }
            };
        }

        // set default value
        if (!self.model.searchMode && self.value == nil && self.model.defaultValue != nil) {
            self.value = FLTrueString(self.model.defaultValue[kFieldRadioKey]);
        }
    }
    return self;
}

- (void)parseModelCurrent {
    if (self.model &&
        self.model.current &&
        [self.model.current isKindOfClass:NSString.class] &&
        [self.model.current length])
    {
        for (NSDictionary *option in self.options) {
            if (option[kFieldRadioKey] == self.model.current) {
                self.value = option[kFieldRadioKey];
                break;
            }
        }
    }
}

- (NSDictionary *)itemData {
    if (self.model && self.value) {
        if (self.checkBoxMode) {
            return @{FLTrueString(self.value): @"true"};
        }
        return @{self.model.key: FLTrueString(self.value)};
    }
    return nil;
}

- (void)resetValues {
    if (self.model.searchMode || self.options.count == 0) {
        self.value = nil;

        if (self.valueWasChanged != nil) {
            self.valueWasChanged();
        }
    }
    else {
        self.value = FLTrueString(self.options[0][kFieldRadioKey]);
    }
}

#pragma mark -

- (FLFieldRadio *)timeFrameField {
    if (!_timeFrameField) {
        for (int idx = 0; idx < self.section.items.count; idx++) {
            FLFieldRadio *item = self.section.items[idx];

            if ([item isKindOfClass:FLFieldRadio.class]) {
                if ([item.model.key isEqualToString:kFieldRadioTimeFrame]) {
                    _timeFrameField = item;
                    _timeFrameIndex = idx;
                    break;
                }
            }
        }
    }
    return _timeFrameField;
}

@end
