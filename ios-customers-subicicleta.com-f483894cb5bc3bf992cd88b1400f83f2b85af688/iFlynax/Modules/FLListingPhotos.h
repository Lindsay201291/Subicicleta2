//
//  FLListingPhotos.h
//  iFlynax
//
//  Created by Alex on 6/4/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLListingPhotosDelegate;

@interface FLListingPhotos : UICollectionView
@property (assign, readwrite, nonatomic) id<FLListingPhotosDelegate> targetDelegate;
@property (strong, nonatomic) NSArray *photosList;
@end

@protocol FLListingPhotosDelegate <NSObject>
@optional
- (void)listingPhotoWasTappedWithIndex:(NSInteger)photoIndex;
@end