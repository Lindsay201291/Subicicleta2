//
//  FLFieldNumber.h
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@interface FLFieldNumber : FLTableViewItem
@property (copy, nonatomic) NSString *valueFrom;
@property (copy, nonatomic) NSString *valueTo;

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
