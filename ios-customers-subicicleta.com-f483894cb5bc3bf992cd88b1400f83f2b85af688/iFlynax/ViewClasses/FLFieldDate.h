//
//  FLFieldDate.h
//  iFlynax
//
//  Created by Alex on 10/13/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

static NSString * const kFieldDateTypeStringSingle = @"single";
static NSString * const kFieldDateTypeStringPeriod = @"period";

typedef NS_ENUM(NSUInteger, FLFieldDateType) {
    FLFieldDateTypeSingle,
    FLFieldDateTypePeriod
};

@interface FLFieldDate : FLTableViewItem
@property (copy, nonatomic) NSString *valueFrom;
@property (copy, nonatomic) NSString *valueTo;
@property (assign, nonatomic) FLFieldDateType type;

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
