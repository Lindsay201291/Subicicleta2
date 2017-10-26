//
//  FLYouTubeMGItemCell.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLMediaGallery.h"
#import "FLYouTubeMGItemModel.h"

@interface FLYouTubeMGItemCell : FLMediaGalleryItemCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) FLYouTubeMGItemModel *data;

@property (readonly, getter=isDataCustiomized) BOOL dataCustomized;

- (void)customizeFromData;

@end
