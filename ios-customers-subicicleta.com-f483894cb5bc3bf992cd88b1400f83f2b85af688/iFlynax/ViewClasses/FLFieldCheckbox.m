//
//  FLFieldCheckbox.m
//  iFlynax
//
//  Created by Alex on 9/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldCheckbox.h"

#import "FLTableViewOptionsController.h"
#import "RERadioItem.h"

static NSString * const kItemKey   = @"key";
static NSString * const kItemName  = @"name";

@implementation FLFieldCheckbox

+ (instancetype)fromModel:(FLFieldModel *)model parentVC:(UIViewController *)parentVC {
    return [[self alloc] initWithModel:model parentVC:parentVC];
}

- (instancetype)initWithModel:(FLFieldModel *)model parentVC:(UIViewController *)parentVC {

    self = [super initWithTitle:model.name
                          value:nil
               selectionHandler:^(REMultipleChoiceItem *item) {
                   NSMutableArray *options = [NSMutableArray array];
                   for (NSDictionary *entry in model.values) {
                       [options addObject:[RERadioItem itemWithTitle:FLCleanString(entry[kItemName])]];
                   }

                   // Present options controller
                   FLTableViewOptionsController *optionsController;
                   optionsController = [[FLTableViewOptionsController alloc]
                                        initWithItem:item
                                        options:options
                                        multipleChoice:YES
                                        completionHandler:^(RETableViewItem *option) {
                                            // TODO: required to check it later..
                                            if ([parentVC respondsToSelector:@selector(tableView)]) {
                                                UITableView *tableView = [parentVC performSelector:@selector(tableView)];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if ([self isValid]) {
                                                        [self cellOfThisItem].textLabel.textColor = [UIColor blackColor];
                                                    }
                                                    [tableView reloadData];
                                                });
                                            }
                                        }];
                   optionsController.title = model.name;
                   optionsController.rowItem = self;

                   [parentVC presentViewController:optionsController.flNavigationController animated:YES completion:nil];
               }];

    if (self) {
        self.model      = model;
        self.title      = model.name;
        self.cellHeight = 60;

        [self parseModelCurrent];
    }
    return self;
}

- (void)setValue:(NSArray *)value {
    [super setValue:value];

    if (value.count) {
        self.title = [value componentsJoinedByString:@", "];
    }
    else {
        self.title = self.model.name;
    }
    self.detailLabelText = nil;
}

- (void)parseModelCurrent {
    if (self.model &&
        self.model.current &&
        [self.model.current isKindOfClass:NSString.class] &&
        [self.model.current length])
    {
        NSArray *_current = [self.model.current componentsSeparatedByString:@","];
        NSMutableArray *_names = [NSMutableArray new];

        for (NSDictionary *entry in self.model.values) {
            if ([_current containsObject:entry[kItemKey]]) {
                [_names addObject:entry[kItemName]];
            }
        }
        self.value = _names;
    }
}

#pragma mark -

- (NSDictionary *)itemData {
    NSMutableArray *_values = [NSMutableArray new];
    
    if (self.value.count) {
        [_values addObject:@(0)];

        for (NSDictionary *entry in self.model.values) {
            if ([self.value containsObject:entry[kItemName]]) {
                [_values addObject:entry[kItemKey]];
            }
        }
    }

    if (self.model.searchMode && _values.count == 0) {
        return nil;
    }
    return @{self.model.key : _values};
}

- (void)resetValues {
    self.value = @[];
}

- (BOOL)isValid {
    if (self.model.required && !self.value.count) {
        [self cellOfThisItem].textLabel.textColor = FLHexColor(kColorFieldHasError);
        return NO;
    }
    return YES;
}

#pragma mark - tmp method

- (UITableViewCell *)cellOfThisItem {
    if (self.rowCell != nil) {
        return self.rowCell;
    }

    NSUInteger row = [[self.section items] indexOfObject:self];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:self.section.index];
    return [self.section.tableViewManager.tableView cellForRowAtIndexPath:indexPath];
}

@end
