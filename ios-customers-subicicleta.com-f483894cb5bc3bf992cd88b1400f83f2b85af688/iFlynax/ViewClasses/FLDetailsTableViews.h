//
//  FLDetailsTableViews.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 12/3/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLListingPhotos.h"
#import "FLAdFavoriteButton.h"
#import "FLAttributedLabel.h"

@interface FLLabel : UILabel

@end

@interface FLDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet FLLabel *titleLabel;
@property (weak, nonatomic) IBOutlet FLAttributedLabel *detailLabel;
@property (assign, nonatomic) NSString *condition;
@end

@interface FLDetailsTableViewHeader : UIView

@property (weak, nonatomic) IBOutlet FLLabel *titleLabel;
@property (weak, nonatomic) IBOutlet FLLabel *priceLabel;
@property (weak, nonatomic) IBOutlet FLAdFavoriteButton *favoriteAdsButton;
@property (weak, nonatomic) IBOutlet UIButton *adCommentsButton;
@property (weak, nonatomic) IBOutlet FLListingPhotos *photosCollection;
@property (nonatomic) BOOL showPhotosCollectionView;

@end

@interface FLDetailsTableView : UITableView

@property (weak, nonatomic) IBOutlet FLDetailsTableViewHeader *headerView;

@end
