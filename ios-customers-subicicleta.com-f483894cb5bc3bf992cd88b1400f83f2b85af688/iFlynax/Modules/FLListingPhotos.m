//
//  FLListingPhotos.m
//  iFlynax
//
//  Created by Alex on 6/4/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLListingPhotos.h"
#import "FLPhotosCell.h"

@interface FLListingPhotos () <UICollectionViewDelegate, UICollectionViewDataSource> {
    UIImage *_placeholderLoading;
}
@end

@implementation FLListingPhotos

- (void)awakeFromNib {
    [super awakeFromNib];

	self.backgroundColor = FLHexColor(kColorBackgroundColor);
	self.dataSource = self;
	self.delegate = self;

	_photosList = @[];
    _placeholderLoading = [UIImage imageNamed:@"loading30x30"];
}

#pragma mark - setters

- (void)setPhotosList:(NSArray *)photosList {
	_photosList = photosList;

	dispatch_async(dispatch_get_main_queue(), ^{
		[self reloadData];
	});
}

#pragma mark --

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photosList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FLPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kStoryBoardDetailsCollectionItemCustomCell
																		   forIndexPath:indexPath];
    NSURL *photoUrl = URLIFY(_photosList[indexPath.row][@"photo"]);
    cell.thumbnail.image = _placeholderLoading;

    if (photoUrl.scheme.length) {
        NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:photoUrl];
        [thumbnailRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        [cell.thumbnail setImageWithURLRequest:thumbnailRequest
                              placeholderImage:[UIImage imageNamed:@"loading30x30"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           cell.thumbnail.image = [image imageCroppedToFitSize:cell.thumbnail.size];
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           [self setNoImageForCell:cell];
                                       }];
    }
    else {
        [self setNoImageForCell:cell];
    }
    return cell;
}

- (void)setNoImageForCell:(FLPhotosCell *)cell {
    cell.thumbnail.image = [UIImage imageNamed:@"no_image"];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_targetDelegate != nil && [_targetDelegate respondsToSelector:@selector(listingPhotoWasTappedWithIndex:)]) {
        [_targetDelegate listingPhotoWasTappedWithIndex:indexPath.row];
    }
}

@end
