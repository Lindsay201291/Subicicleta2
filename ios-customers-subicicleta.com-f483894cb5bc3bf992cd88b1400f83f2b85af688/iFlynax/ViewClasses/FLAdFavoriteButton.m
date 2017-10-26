//
//  FLAdFavoriteButton.m
//  iFlynax
//
//  Created by Alex on 11/10/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAdFavoriteButton.h"

@implementation FLAdFavoriteButton

- (void)awakeFromNib {
    [super awakeFromNib];

	[self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Setters

- (void)setAdId:(NSInteger)adId {
	_adId = adId;
	_favorite = [[FLFavorites sharedInstance] isFavoriteWithId:_adId];
}

#pragma mark -

- (void)dofakeTapAction {
    [self tapped];
}

- (void)tapped {
	_favorite = !_favorite;

	if (_favorite)
		[[FLFavorites sharedInstance] addToFavorites:_adId];
	else
		[[FLFavorites sharedInstance] removeFromFavorites:_adId];

    // send the notification to all subscribers
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFavoriteBtnDidTap object:self];

	[self updateCurrentState];
}

- (void)updateCurrentState {
	NSString *favoriteImageName = _favorite ? @"rfav30x30" : @"afav30x30";
	UIImage *favoritesBackgroundImage = [UIImage imageNamed:favoriteImageName];
	[self setBackgroundImage:favoritesBackgroundImage forState:UIControlStateNormal];
}

@end
