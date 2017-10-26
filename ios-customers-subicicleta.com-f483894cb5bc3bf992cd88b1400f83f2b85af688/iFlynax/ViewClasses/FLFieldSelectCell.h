//
//  FLFieldSelectCell.h
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldSelect.h"
#import "FLFieldCell.h"

@interface FLFieldSelectCell : FLFieldCell
@property (strong, nonatomic) FLFieldSelect *item;
@property (nonatomic, getter=isTwoFields, readonly) BOOL twoFields;
@end
