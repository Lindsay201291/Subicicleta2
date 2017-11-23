//
//  FLFieldDate.m
//  iFlynax
//
//  Created by Alex on 10/13/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLFieldDate.h"

@implementation FLFieldDate

+ (instancetype)fromModel:(FLFieldModel *)model {
    return [[self alloc] fromModel:model];
}

- (instancetype)fromModel:(FLFieldModel *)model {
    if (self) {
        self.model       = model;
        self.cellHeight  = 60;
        self.placeholder = model.name;

        self.type = (model.searchMode ||
                     ([model.data isKindOfClass:NSString.class]
                      && [model.data isEqualToString:kFieldDateTypeStringPeriod]))
        ? FLFieldDateTypePeriod
        : FLFieldDateTypeSingle;

        [self resetValues];
        [self parseModelCurrent];
    }
    return self;
}

- (void)parseModelCurrent {
    if (self.model && self.model.current) {
        if (self.type == FLFieldDateTypePeriod &&
            [self.model.current isKindOfClass:NSDictionary.class])
        {
            // edit
            self.valueFrom = FLCleanString(self.model.current[@"from"]);
            self.valueFrom = [self stringToDate:self.valueFrom];
            // edit
            self.valueTo   = FLCleanString(self.model.current[@"to"]);
            self.valueTo   = [self stringToDate:self.valueTo];
        }
        else if (self.type == FLFieldDateTypeSingle &&
                 [self.model.current isKindOfClass:NSString.class] &&
                 [self.model.current length])
        {
            // edit
            self.valueFrom = FLCleanString(self.model.current);
            self.valueFrom = [self stringToDate:self.valueFrom];
        }
    }
}

#pragma mark -

- (NSDictionary *)itemData {
    if (!self.model) {
        return nil;
    }

    if (self.type == FLFieldDateTypePeriod) {
        if (self.model.searchMode && [self.valueFrom isEmpty] && [self.valueTo isEmpty]) {
            return nil;
        }
        return @{self.model.key : @{kItemFrom : FLCleanString(self.valueFrom),
                                    kItemTo   : FLCleanString(self.valueTo)}};
    }
    else if (self.type == FLFieldDateTypeSingle) {
        if (self.model.searchMode && [self.valueFrom isEmpty]) {
            return nil;
        }
        return @{self.model.key : FLCleanString(self.valueFrom)};
    }
    return nil;
}

- (void)resetValues {
    self.valueFrom = @"";
    self.valueTo   = @"";
}

- (BOOL)isValid {
    if (self.model.required) {
        
        if ((self.type == FLFieldDateTypeSingle && [_valueFrom isEmpty]) ||
            (self.type == FLFieldDateTypePeriod && ([_valueFrom isEmpty] || [_valueTo isEmpty])))
        {
            self.errorMessage = FLLocalizedString(@"valider_fillin_the_field");
            return NO;
        }
    }
    return YES;
}

- (NSString *)stringToDate:(NSString *)date {
    NSString *dateString = date;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateAux = [format dateFromString:dateString];
    [format setDateFormat:@"dd-MM-yyyy"];
    NSString *finalDateStr = [format stringFromDate:dateAux];
    
    return finalDateStr;
}

@end
