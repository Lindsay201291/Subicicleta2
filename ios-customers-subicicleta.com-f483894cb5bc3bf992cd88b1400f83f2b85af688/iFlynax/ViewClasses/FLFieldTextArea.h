//
//  FLFieldTextArea.h
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@interface FLFieldTextArea : FLTableViewItem
@property (copy, nonatomic) NSString *value;

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
