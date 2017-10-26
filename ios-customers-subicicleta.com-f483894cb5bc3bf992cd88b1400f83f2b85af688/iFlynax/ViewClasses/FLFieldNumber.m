//
//  FLFieldNumber.m
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldNumber.h"

@implementation FLFieldNumber

+ (instancetype)fromModel:(FLFieldModel *)model {
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(FLFieldModel *)model {
    if (self) {
        self.model        = model;
        self.valueFrom    = FLCleanString(model.current);
        self.valueTo      = @"";
        self.placeholder  = model.name;
        self.cellHeight   = 60;
    }
    return self;
}

- (NSDictionary *)itemData {
    if (!self.model) {
        return nil;
    }

    if (self.model.searchMode) {
        if ([self.valueFrom isEmpty] && [self.valueTo isEmpty]) {
            return nil;
        }
        return @{self.model.key : @{kItemFrom : FLCleanString(self.valueFrom),
                                    kItemTo   : FLCleanString(self.valueTo)}};
    }

    if (![self.valueFrom isEmpty]) {
        return @{self.model.key : FLCleanString(self.valueFrom)};
    }
    return nil;
}

- (void)resetValues {
    self.valueFrom = @"";
    self.valueTo   = @"";
}

- (BOOL)isValid {
    if (self.model.required && [self.valueFrom isEmpty]) {
        self.errorMessage = FLLocalizedString(@"valider_fillin_the_field");
        return NO;
    }
    return YES;
}

@end
