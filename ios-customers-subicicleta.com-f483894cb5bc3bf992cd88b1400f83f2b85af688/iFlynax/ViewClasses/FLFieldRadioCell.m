//
//  FLFieldRadioCell.m
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldRadioCell.h"
#import "FLRadioButton.h"

static NSString * const kEntryKey  = @"key";
static NSString * const kEntryName = @"name";
static CGFloat    const kBtnHeight = 28;

@interface FLFieldRadioCell () <FLRadioButtonDelegate>
@property (weak, nonatomic) IBOutlet UIView *radioBox;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMarginConstraint;
@end

@implementation FLFieldRadioCell
@dynamic item;

- (void)cellWillAppear {
    [self.radioBox removeAllSubviews];

    if (self.item.checkBoxMode) {
        self.titleLabel.text = nil;
        _leftMarginConstraint.constant = 0;
    } else {
        self.titleLabel.text = self.item.caption;
        _leftMarginConstraint.constant = 15;
    }

    if (self.item.options && self.item.options.count) {
        NSMutableArray *buttons = [@[] mutableCopy];
        CGFloat yPos = self.radioBox.frame.origin.y;
        NSArray *fieldValues = [self fiedValues];

        for (int idx = 0; idx < fieldValues.count; idx++) {
            NSDictionary *entry = fieldValues[idx];

            NSString *title = FLCleanString(entry[kEntryName]);
            FLRadioButton *radioBtn = [[FLRadioButton alloc] initWithFrame:CGRectZero buttonTitle:title];
            radioBtn.titleLabel.text = title;
            radioBtn.userInfo = FLCleanString(entry[kEntryKey]);
            radioBtn.iconSquare = self.item.checkBoxMode;
            radioBtn.delegate = self;

            if (self.item.model.searchMode && self.item.checkBoxMode == NO) {
                radioBtn.multipleSelectionEnabled = YES;
            }

            // from current calue
            if (self.item.value && self.item.value == radioBtn.userInfo && radioBtn.selected == NO) {
                radioBtn.selected = YES;
            }
            // set selected & default value if not checkbox mode
            else if ((self.item.checkBoxMode == NO && self.item.model.searchMode == NO)
                     && self.item.value == nil && idx == 0 && radioBtn.selected == NO)
            {
                radioBtn.selected = YES;
                [self setItemValue:radioBtn.userInfo];
            }

            radioBtn.otherButtons = [buttons copy];
            [buttons addObject:radioBtn];

            [self.radioBox insertSubview:radioBtn atIndex:idx];

            // set button constraint
            radioBtn.translatesAutoresizingMaskIntoConstraints = NO;

            [self addConstraint:[NSLayoutConstraint constraintWithItem:radioBtn
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.radioBox
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0f
                                                              constant:0]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.radioBox
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:radioBtn
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0f
                                                              constant:0]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:radioBtn
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0f
                                                              constant:yPos]];

            [radioBtn addConstraint:[NSLayoutConstraint constraintWithItem:radioBtn
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0f
                                                                  constant:kBtnHeight]];
            yPos += kBtnHeight + 8;
        }
    }
}

- (NSArray *)fiedValues {
    NSArray *values = @[];

    if ([self.item.options isKindOfClass:NSArray.class]) {
        values = self.item.options;
    }
    else if ([self.item.options isKindOfClass:NSDictionary.class]) {
        values = [(NSDictionary *)self.item.options allValues];
    }
    return values;
}

- (void)setItemValue:(id)value {
    self.item.value = value;
    
    if (self.item.valueWasChanged) {
        self.item.valueWasChanged();
    }
}

#pragma mark - FLRadioButtonDelegate

- (void)FLRadioButtonDidTapped:(FLRadioButton *)button {
    if (self.item.model.searchMode == YES && self.item.checkBoxMode == NO) {
        if (self.item.value != nil && button.selectedButtons.count > 1) {
            if (((FLRadioButton *)button.selectedButtons[1]).selected) {
                for (FLRadioButton *otherBtn in button.otherButtons) {
                    if (otherBtn.selected == YES) {
                        [otherBtn setSelected:NO];
                    }
                }
            }
        }
    }

    if (button.selected == NO) {
        self.item.value = nil;
        return;
    }

    if (self.item.checkBoxMode && self.item.value != nil) {
        self.item.value = nil;
        button.selected = NO;
        return;
    }

    [self setItemValue:button.userInfo];
}

@end
