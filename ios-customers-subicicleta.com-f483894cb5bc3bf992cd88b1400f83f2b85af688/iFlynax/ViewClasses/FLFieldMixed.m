//
//  FLFieldMixed.m
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldMixed.h"

@implementation FLFieldMixed

+ (instancetype)fromModel:(FLFieldModel *)model {
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(FLFieldModel *)model {
    if (self) {
        self.model       = model;
        self.placeholder = model.name;
        self.cellHeight  = 60;
        self.options     = model.values;

        [self resetValues];
        [self parseModelCurrent];
    }
    return self;
}

- (void)parseModelCurrent {
    if (self.model &&
        self.model.current &&
        [self.model.current isKindOfClass:NSString.class] &&
        [self.model.current length])
    {
        // exp: text|mixed_2
        NSArray *companents = [self.model.current componentsSeparatedByString:@"|"];
        if (companents.count) {
            self.valueFrom    = FLCleanString(companents[0]);
            NSString *_svalue = FLCleanString(companents[1]);

            if (_svalue) {
                for (NSDictionary *option in self.options) {
                    if ([option[kItemKey] isEqualToString:_svalue]) {
                        self.selectValue = option;
                        break;
                    }
                }
            }
        }
    } else if ([self modelDefaultValue] != nil) {
        self.selectValue = self.model.defaultValue;
    }
}

- (NSDictionary *)modelDefaultValue {
    if (self.model &&
        self.model.defaultValue != nil &&
        [self.model.defaultValue isKindOfClass:NSDictionary.class])
    {
        return self.model.defaultValue;
    }
    return nil;
}

- (NSDictionary *)itemData {
    if (self.model == nil) {
        return nil;
    }

    NSString *subValueKey = (self.model.type == FLFieldTypePrice)
    ? @"currency"
    : @"df";

    if (self.model.searchMode) {
        if ([self.valueFrom isEmpty] && [self.valueTo isEmpty]) {
            return nil;
        }
        return @{self.model.key: @{kItemFrom  : FLCleanString(self.valueFrom),
                                   kItemTo    : FLCleanString(self.valueTo),
                                   subValueKey: FLCleanString(self.selectValue[kItemKey])}};
    }

    if (![self.valueFrom isEmpty]) {
        return @{self.model.key: @{kItemValue : FLCleanString(self.valueFrom),
                                   subValueKey: FLCleanString(self.selectValue[kItemKey])}};
    }
    return nil;
}

- (void)resetValues {
    self.valueFrom   = @"";
    self.valueTo     = @"";
    self.selectValue = [self modelDefaultValue];
}

- (BOOL)isValid {
    if (self.model.required && [self.valueFrom isEmpty]) {
        self.errorMessage = FLLocalizedString(@"valider_fillin_the_field");
        return NO;
    }
    return YES;
}

@end
