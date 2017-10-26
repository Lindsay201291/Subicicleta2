//
//  FLAdsViewCell.h
//  iFlynax
//
//  Created by Alex on 10/31/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLListingViewCell.h"
#import "FLAdFavoriteButton.h"

@interface FLAdsViewCell : FLListingViewCell

@property (weak, nonatomic) IBOutlet FLAdFavoriteButton *favoriteButton;

@end
