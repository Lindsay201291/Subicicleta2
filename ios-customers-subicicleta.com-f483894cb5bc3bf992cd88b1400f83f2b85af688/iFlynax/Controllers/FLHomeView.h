//
//  FLHomeView.h
//  iFlynax
//
//  Created by Alex on 4/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLViewController.h"

@interface FLHomeView : FLViewController

@end

@interface FLHomeViewControllerView: UIView
- (void)updateNecessaryConstraintsForBanner:(FLGoogleAdModel *)banner;
@end
