//
//  FLFieldTextCell.h
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldText.h"
#import "FLTextField.h"
#import "FLFieldCell.h"

@interface FLFieldTextCell : FLFieldCell
@property (strong, nonatomic) FLFieldText *item;
@property (weak, nonatomic) IBOutlet FLTextField *textField;
@end
