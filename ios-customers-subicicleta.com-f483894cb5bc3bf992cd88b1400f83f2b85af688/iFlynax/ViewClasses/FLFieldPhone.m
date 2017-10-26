//
//  FLFieldPhone.m
//  iFlynax
//
//  Created by Alex on 9/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldPhone.h"

@implementation FLFieldPhone

+ (instancetype)fromModel:(FLFieldModel *)model {
    return [[self alloc] fromModel:model];
}

- (instancetype)fromModel:(FLFieldModel *)model {
    if (self) {
        self.model       = model;
        self.cellHeight  = 60;
        self.codeField   = NO;
        self.extField    = NO;
        self.phoneString = FLCleanString(self.model.current);
        self.placeholder = FLCleanString(self.model.name);

        [self resetValues];
        [self parseModelData];
        [self parseModelCurrent];
    }
    return self;
}

- (NSDictionary *)itemData {
    if (self.model.key) {
        return @{self.model.key : @{@"code"   : _valueCode,
                                    @"area"   : _valueArea,
                                    @"number" : _valueNumber,
                                    @"ext"    : _valueExt}};
    }
    return nil;
}

- (void)resetValues {
    _valueCode   = @"";
    _valueArea   = @"";
    _valueNumber = @"";
    _valueExt    = @"";
}

- (BOOL)isValid {
    if (self.model.required) {
        if ((self.codeField && !_valueCode) || !_valueArea || !_valueNumber) {
            self.errorMessage = FLLocalizedString(@"valider_fillin_the_field");
            return NO;
        }
    }
    return YES;
}

#pragma mark -

- (void)parseModelData {
    if (self.model &&
        self.model.data &&
        [self.model.data isKindOfClass:NSString.class])
    {
        // exp: 0|3|7|0
        NSArray *companents = [self.model.data componentsSeparatedByString:@"|"];
        if (companents.count == 4) {
            self.codeField    = FLTrueBool(companents[0]);
            self.areaLength   = FLTrueInteger(companents[1]);
            self.numberLength = FLTrueInteger(companents[2]);
            self.extField     = FLTrueBool(companents[3]);
        }
    }
}

- (void)parseModelCurrent {
    if (self.model &&
        self.model.values &&
        [self.model.values isKindOfClass:NSDictionary.class])
    {
        self.valueCode   = FLTrueString(self.model.values[@"code"]);
        self.valueArea   = FLTrueString(self.model.values[@"area"]);
        self.valueNumber = FLTrueString(self.model.values[@"number"]);
        self.valueExt    = FLTrueString(self.model.values[@"ext"]);
    }
}

@end
