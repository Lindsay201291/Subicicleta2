//
//  FLAdsCollectionCell.h
//  iFlynax
//
//  Created by Alex on 4/29/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLAdsCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *adThumbnail;
@property (weak, nonatomic) IBOutlet UIView *adDetailsMask;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UILabel *adPrice;
@end