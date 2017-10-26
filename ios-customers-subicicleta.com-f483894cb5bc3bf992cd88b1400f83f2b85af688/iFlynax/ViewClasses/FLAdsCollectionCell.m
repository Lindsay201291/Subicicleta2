//
//  FLAdsCollectionCell.m
//  iFlynax
//
//  Created by Alex on 4/29/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAdsCollectionCell.h"

@implementation FLAdsCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];

	self.autoresizesSubviews = YES;
	_adDetailsMask.backgroundColor = [UIColor hexColor:kColorBarTintColor alpha:.75f];
    _adPrice.textColor = FLHexColor(kColorThemeHomePrice);
}

@end
