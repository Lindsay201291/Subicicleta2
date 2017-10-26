//
//  FLFieldSelectCell.m
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldSelectCell.h"
#import "FLDropDown.h"

typedef NS_ENUM(NSInteger, FLDropDownField) {
    FLDropDownFieldFrom,
    FLDropDownFieldTo
};

@interface FLFieldSelectCell ()
@property (weak, nonatomic) IBOutlet FLDropDown *dropDownFrom;
@property (weak, nonatomic) IBOutlet FLDropDown *dropDownTo;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *equaWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *horConstraint;
@end

@implementation FLFieldSelectCell
@dynamic item;

- (void)setTwoFields:(BOOL)twoFields {
    _equaWidthConstraint.active = twoFields;
    _horConstraint.active = twoFields;
    _dropDownTo.hidden = twoFields ? NO : YES;
    _twoFields = twoFields;
}

- (void)setupDropDownField:(FLDropDown *)dropDown field:(FLDropDownField)field {
    [dropDown clearDataSource];

    if (_twoFields) {
        dropDown.title = (field == FLDropDownFieldFrom
                          ? self.item.placeholderFrom
                          : self.item.placeholderTo);
    } else {
        if (self.item.model.searchMode) {
            dropDown.title = FLLocalizedStringReplace(@"placeholder_any_field",
                                                      @"{field}",
                                                      self.item.placeholder);
        } else {
            dropDown.title = self.item.placeholder;
        }
    }

    dropDown.loading = self.item.isLoadingOptions;

    dropDown.inputAccessoryView = self.actionBar;
    dropDown.enabled = self.item.options.count >= 1;

    if ([self.item.options isKindOfClass:NSArray.class]
        && [self.item.options count])
    {
        for (id option in self.item.options) {
            [dropDown addOption:option];
        }
        [dropDown reloadAllComponents];

        __block FLDropDown *weakDropdown = dropDown;

        dropDown.didChangeBlock = ^(id option, NSString *key) {
            id selectedValue = weakDropdown.isSelected ? option : nil;

            if (weakDropdown == _dropDownFrom) {
                self.item.valueFrom = selectedValue;
            } else if (weakDropdown == _dropDownTo) {
                self.item.valueTo = selectedValue;
            }
            self.item.valueChanged = YES;

            if (self.item.errorMessage != nil) {
                [self highlightAsFieldWithError:NO];
            }
        };

        if (dropDown == _dropDownFrom && self.item.valueFrom != nil) {
            [dropDown selectOption:self.item.valueFrom];
        } else if (dropDown == _dropDownTo && self.item.valueTo != nil) {
            [dropDown selectOption:self.item.valueFrom];
        }
        else [dropDown selectOptionAtIndex:0];
    }
}

#pragma mark -

- (void)cellWillAppear {
    self.twoFields = self.item.twoFields;
    self.fieldPlaceholder.text = self.item.placeholder;
    self.item.valueChanged = NO;

    [self setupDropDownField:_dropDownFrom field:FLDropDownFieldFrom];

    if (_twoFields) {
        [self setupDropDownField:_dropDownTo field:FLDropDownFieldTo];
    }

    // errors trigger
    [self highlightAsFieldWithError:(self.item.errorMessage != nil)];
}

- (void)highlightAsFieldWithError:(BOOL)highlighted {
    [self highlightInput:_dropDownFrom highlighted:highlighted];

    if (!highlighted) {
        self.item.errorMessage = nil;
    }
}

+ (BOOL)canFocusWithItem:(FLFieldSelect *)item {
    return item.options.count >= 1;
}

- (UIResponder *)responder {
    return _dropDownFrom.responder;
}

@end
