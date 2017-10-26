//
//  FLImageMediaGallery.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/16/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLMediaGallery.h"
#import "FLImageMGItemCell.h"

typedef NS_ENUM(NSInteger, FLIMGAssetThumbSource) {
    FLIMGAssetThumbSourceResolutionImage,
    FLIMGAssetThumbSourceScreenImage
};

@protocol FLImageMediaGalleryDelegate;

@interface FLImageMediaGallery : FLMediaGallery

@property (strong, nonatomic) FLImageMGItemCell *selectedItemCell;

- (void)loadFromAssets:(NSArray *)assets;
- (void)loadFromArray:(NSArray *)items;

@end

@protocol FLImageMediaGalleryDelegate <FLMediaGalleryDelegate>
@optional

@optional

- (void)imageGallery:(FLImageMediaGallery *)gallery didChangePrimaryItemCell:(FLImageMGItemCell *)fromItemCell toItemCell:(FLImageMGItemCell *)toItemCell;

- (void)imageGallery:(FLImageMediaGallery *)gallery itemDidChangeDescription:(FLImageMGItemCell *)itemCell;

@end
