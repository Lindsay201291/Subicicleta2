//
//  FLFieldBool.m
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldBool.h"

@implementation FLFieldBool

+ (instancetype)fromModel:(FLFieldModel *)model {
    return [[self alloc] fromModel:model];
}

- (instancetype)fromModel:(FLFieldModel *)model {
    if (self) {
        self.model      = model;
        self.cellHeight = 60;
        self.value      = FLTrueBool(model.current);
        self.textAlignment = NSTextAlignmentNatural;
    }
    return self;
}

- (NSDictionary *)itemData {
    if (self.model) {
        return @{self.model.key : @(self.value)};
    }
    return nil;
}

- (void)resetValues {
    self.value = NO; //TODO: check model.default value
}

#pragma mark Error validation

- (NSArray *)errors {
    return [REValidation validateObject:@(self.value) name:self.name validators:self.validators];
}

@end
