//
//  FLMyListingsCell.h
//  iFlynax
//
//  Created by Alex on 10/31/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLListingViewCell.h"

static NSString * const kMyListingShowAccessoryNotification = @"com.flynax.mylistingassessoryshow";

@interface FLMyListingsCell : FLListingViewCell

@property (weak, nonatomic) IBOutlet UIButton *accessoryButton;

@end
