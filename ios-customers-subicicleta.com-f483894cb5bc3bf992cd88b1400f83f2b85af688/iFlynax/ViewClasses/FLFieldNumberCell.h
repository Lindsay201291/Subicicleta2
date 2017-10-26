//
//  FLFieldNumberCell.h
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldCell.h"
#import "FLTextField.h"
#import "FLFieldNumber.h"

@interface FLFieldNumberCell : FLFieldCell
@property (strong, nonatomic) FLFieldNumber *item;
@property (nonatomic, getter=isTwoFields, readonly) BOOL twoFields;
@end
