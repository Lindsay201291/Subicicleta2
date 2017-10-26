//
//  FLAdFavoriteButton.h
//  iFlynax
//
//  Created by Alex on 11/10/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLAdFavoriteButton : UIButton
@property (nonatomic, assign) NSInteger adId;
@property (nonatomic, getter=isFavorite) BOOL favorite;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)updateCurrentState;
- (void)dofakeTapAction;
@end
