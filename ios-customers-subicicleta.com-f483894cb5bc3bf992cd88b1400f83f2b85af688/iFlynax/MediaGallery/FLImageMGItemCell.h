//
//  FLImageMGItemCell.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/16/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLMediaGallery.h"
#import "FLImageMGItemModel.h"

@interface FLImageMGItemCell : FLMediaGalleryItemCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) FLImageMGItemModel *data;

@property (nonatomic, getter=isPrimary) BOOL primary;

@end
