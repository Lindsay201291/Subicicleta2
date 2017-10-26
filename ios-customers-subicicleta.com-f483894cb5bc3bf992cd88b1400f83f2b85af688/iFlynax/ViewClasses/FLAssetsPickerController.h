//
//  FLAssetsPickerController.h
//  iFlynax
//
//  Created by Alex on 1/15/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "UzysAssetsPickerController.h"

@protocol FLAssetsPickerControllerDelegate;

@interface FLAssetsPickerController : UzysAssetsPickerController

@end

@protocol FLAssetsPickerControllerDelegate <UzysAssetsPickerControllerDelegate>

@optional

- (void)flAssetsPickerControllerDidDisappear:(FLAssetsPickerController *)picker;

@end
