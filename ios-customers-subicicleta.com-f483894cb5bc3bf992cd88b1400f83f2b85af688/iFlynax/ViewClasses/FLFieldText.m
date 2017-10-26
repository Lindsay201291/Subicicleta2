//
//  FLFieldText.m
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldText.h"

@implementation FLFieldText

+ (instancetype)fromModel:(FLFieldModel *)model {
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(FLFieldModel *)model {
    if (self) {
        self.model        = model;
        self.value        = FLTrueString(model.current);
        self.placeholder  = model.name;
        self.cellHeight   = 60;
        self.keyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (NSDictionary *)itemData {
    if (self.model) {
        if (self.model.searchMode && [self.value isEmpty]) {
            return nil;
        }
        return @{self.model.key : FLTrueString(self.value)};
    }
    return nil;
}

- (void)resetValues {
    self.value = @"";
}

- (BOOL)isValid {
    if (self.model.required && [self.value isEmpty]) {
        self.errorMessage = FLLocalizedString(@"valider_fillin_the_field");
        return NO;
    }
    return YES;
}

@end
