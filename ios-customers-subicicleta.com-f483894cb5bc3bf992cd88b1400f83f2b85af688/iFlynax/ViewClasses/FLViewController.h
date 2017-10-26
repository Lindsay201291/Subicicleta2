//
//  FLViewController.h
//  iFlynax
//
//  Created by Alex on 4/7/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "GAITrackedViewController.h"
#import "FLGoogleAdModel.h"

@interface FLViewController : GAITrackedViewController

@property (strong, nonatomic) FLGoogleAdModel *googleAd;

- (void)updateNecessaryConstraintsForBannerView;

@end
