//
//  FLTableViewManager.m
//  iFlynax
//
//  Created by Alex on 3/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewManager.h"
#import "FLTableViewItem.h"

@implementation FLTableViewManager

+ (instancetype)withTableView:(UITableView *)tableview {
    FLTableViewManager *manager = [[FLTableViewManager alloc] initWithTableView:tableview];
    manager[@"FLFieldBool"]     = @"FLFieldBoolCell";
    manager[@"FLFieldText"]     = @"FLFieldTextCell";
    manager[@"FLFieldMixed"]    = @"FLFieldMixedCell";
    manager[@"FLFieldRadio"]    = @"FLFieldRadioCell";
    manager[@"FLFieldSelect"]   = @"FLFieldSelectCell";
    manager[@"FLFieldNumber"]   = @"FLFieldNumberCell";
    manager[@"FLFieldTextArea"] = @"FLFieldTextAreaCell";
    manager[@"FLFieldPhone"]    = @"FLFieldPhoneCell";
    manager[@"FLFieldCheckbox"] = @"RETableViewOptionCell";
    manager[@"FLFieldDate"]     = @"FLFieldDateCell";
    manager[@"FLFieldAccept"]   = @"FLFieldAcceptCell";

    manager.fieldAcceptTitle = @"";
    manager.formAccepted     = YES;

    return manager;
}

#pragma mark - Helpers

- (void)enumerateItemsUsingBlock:(void (^)(FLTableViewItem *item))itemBlock {
    if (!itemBlock)
        return;

    for (RETableViewSection *section in self.sections) {
        if (section.items) {
            for (FLTableViewItem *item in section.items) {
                itemBlock(item);
            }
        }
    }
}

- (NSDictionary *)formValues {
    NSMutableDictionary *data = [@{} mutableCopy];

    [self enumerateItemsUsingBlock:^(FLTableViewItem *item) {
        if ([item respondsToSelector:@selector(itemData)]) {
            NSDictionary *idata = [item performSelector:@selector(itemData)];

            // Skip time_frame value if sale_rent field is 1 (Sale)
            if (idata && [item isKindOfClass:FLFieldRadio.class]) {
                NSString *_fieldKey = [[idata allKeys] firstObject];
                if ([_fieldKey isEqualToString:@"time_frame"] && FLTrueInt(data[@"sale_rent"]) == 1) {
                    idata = nil;
                }
            }

            if (idata != nil) {
                [data addEntriesFromDictionary:idata];
            }
        }
    }];

    return data;
}

- (BOOL)isValidForm {
    BOOL resultValid = YES;

    for (RETableViewSection *section in self.sections) {
        for (FLTableViewItem *item in section.items) {
            if ([item isKindOfClass:FLFieldAccept.class]) {
                _formAccepted = [(FLFieldAccept *)item isAccepted];
                _fieldAcceptTitle = item.model.name;
            }
            else if ([item respondsToSelector:@selector(isValid)]) {
                if (![item isValid] && resultValid) {
                    resultValid = NO;
                }
            }
        }
    }
    return resultValid;
}

- (void)resetForm {
    [self enumerateItemsUsingBlock:^(RETableViewItem *item) {
        if ([item respondsToSelector:@selector(resetValues)]) {
            [item performSelector:@selector(resetValues)];
        }
    }];
}

#pragma mark - Deprecated

- (NSArray *)errors {
    return @[@"Depricated! - use isValidForm instead"];
}

@end
