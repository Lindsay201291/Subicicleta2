//
//  FLAddListingController.h
//  iFlynax
//
//  Created by Alex on 3/12/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "FLMyAdShortDetailsModel.h"
#import "FLNavigationController.h"

@interface FLAddListingController : FLViewController
@property (weak, readonly, nonatomic) FLNavigationController *flNavigationController;
@property (strong, nonatomic) FLMyAdShortDetailsModel *listing;
@property (nonatomic, getter=isEditMode) BOOL editMode;
@end
