//
//  FLFieldAccept.m
//  iFlynax
//
//  Created by Alex on 10/13/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLFieldAccept.h"

@implementation FLFieldAccept

+ (instancetype)fromModel:(FLFieldModel *)model parentVC:(UIViewController *)parentVC {
    return [[self alloc] fromModel:model parentVC:parentVC];
}

+ (NSString *)agreeFieldRequiredMessage:(NSString *)fieldName {
    return FLLocalizedStringReplace(@"alert_accept_agreement_required", @"{field}", fieldName);
}

- (instancetype)fromModel:(FLFieldModel *)model parentVC:(UIViewController *)parentVC {
    if (self) {
        self.parentVC     = parentVC;
        self.model        = model;
        self.cellHeight   = 60;
        self.value        = NO;
        self.errorTrigger = NO;
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
    self.value = NO;
}

- (BOOL)isAccepted {
    if (!self.value) {
        self.errorTrigger = YES;
    }
    return self.value;
}

@end
