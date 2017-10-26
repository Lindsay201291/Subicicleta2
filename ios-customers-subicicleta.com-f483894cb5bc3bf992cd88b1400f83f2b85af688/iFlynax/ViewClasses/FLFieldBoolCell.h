//
//  FLFieldBoolCell.h
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldCell.h"
#import "FLFieldBool.h"

@interface FLFieldBoolCell : FLFieldCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (strong, readwrite, nonatomic) FLFieldBool *item;
@end
