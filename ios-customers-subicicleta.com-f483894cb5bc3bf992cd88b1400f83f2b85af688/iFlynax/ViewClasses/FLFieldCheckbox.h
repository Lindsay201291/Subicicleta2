//
//  FLFieldCheckbox.h
//  iFlynax
//
//  Created by Alex on 9/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "REMultipleChoiceItem.h"

@interface FLFieldCheckbox : REMultipleChoiceItem
@property (strong, nonatomic) FLFieldModel *model;
@property (strong, nonatomic) UITableViewCell *rowCell;

+ (instancetype)fromModel:(FLFieldModel *)model parentVC:(UIViewController *)parentVC;

- (NSDictionary *)itemData;
- (void)resetValues;
- (BOOL)isValid;
@end
