//
//  FLTableViewOptionsController.h
//  iFlynax
//
//  Created by Alex on 10/22/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "RETableViewOptionsController.h"
#import "FLNavigationController.h"
#import "FLFieldCheckbox.h"

@interface FLTableViewOptionsController : RETableViewOptionsController
@property (weak, readonly, nonatomic) FLNavigationController *flNavigationController;
@property (strong, nonatomic) FLFieldCheckbox *rowItem;
@end
