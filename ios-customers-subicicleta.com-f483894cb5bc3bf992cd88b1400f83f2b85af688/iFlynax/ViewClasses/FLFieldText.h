//
//  FLFieldText.h
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@interface FLFieldText : FLTableViewItem
@property (copy, nonatomic) NSString *value;
@property (assign, nonatomic) UIKeyboardType keyboardType;

@property (copy, nonatomic) void (^textFieldDidChange)(id item);
@property (copy, nonatomic) void (^textFieldDidEndEditing)(id item);

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
