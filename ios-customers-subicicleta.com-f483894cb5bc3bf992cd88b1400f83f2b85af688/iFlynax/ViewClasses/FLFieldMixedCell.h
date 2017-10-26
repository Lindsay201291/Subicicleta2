//
//  FLFieldMixedCell.h
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldCell.h"
#import "FLFieldMixed.h"

@interface FLFieldMixedCell : FLFieldCell
@property (strong, nonatomic) FLFieldMixed *item;
@property (nonatomic, getter=isTwoFields, readonly) BOOL twoFields;
@end
