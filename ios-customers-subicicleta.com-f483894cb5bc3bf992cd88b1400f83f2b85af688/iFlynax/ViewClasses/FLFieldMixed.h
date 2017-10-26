//
//  FLFieldMixed.h
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@interface FLFieldMixed : FLTableViewItem
@property (strong, nonatomic) NSArray      *options;
@property (copy, nonatomic  ) NSString     *valueFrom;
@property (copy, nonatomic  ) NSString     *valueTo;
@property (strong, nonatomic) NSDictionary *selectValue;

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
