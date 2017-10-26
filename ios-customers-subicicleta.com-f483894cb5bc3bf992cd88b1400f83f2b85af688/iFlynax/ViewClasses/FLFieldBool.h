//
//  FLFieldBool.h
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "REBoolItem.h"

@interface FLFieldBool : REBoolItem
@property (strong, nonatomic) FLFieldModel *model;

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
