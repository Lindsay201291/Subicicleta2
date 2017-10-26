//
//  FLFieldTextArea.m
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldTextArea.h"

@implementation FLFieldTextArea

+ (instancetype)fromModel:(FLFieldModel *)model {
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(FLFieldModel *)model {
    if (self) {
        self.model       = model;
        self.placeholder = model.name;
        self.cellHeight  = 200;
        self.value       = FLCleanString(model.current);
    }
    return self;
}

- (NSDictionary *)itemData {
    if (self.model) {
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
