//
//  FLNavigationController.h
//  iFlynax
//
//  Created by Alex on 4/25/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface FLMainNavigation : UINavigationController

/**
 *	Description
 *	@param sender sender description
 */
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender;
@end