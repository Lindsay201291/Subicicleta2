//
//  FLListingViewCell.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 8/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingViewCell.h"
#import "FLGraphics.h"
#import "FLDetailsTableViews.h"
#import "FLPhotosCount.h"
#import "FLListingCellBackgroundView.h"

static NSString * const kColorAdCellNormal   = @"d7d7d7";
static NSString * const kColorAdCellFeatured = @"e9d3ad";

static NSString * const kListingPhotoDeniedByType = @"ltype_denied_photos";
static NSString * const kListingPhotoNotExists    = @"listing_photo_not_exists";

@interface FLListingViewCell ()

@property (weak, nonatomic) IBOutlet FLLabel *adTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *adSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *adPriceLabel;
@property (weak, nonatomic) IBOutlet FLPhotosCount *photosCountView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adThumbWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adSubTitleHeightConstraint;

@property (nonatomic) BOOL showImage;
@property (strong, nonatomic) UIImage *placeholderImage;
@end

@implementation FLListingViewCell {
    CGFloat _adThumbWidthConstraintDefault;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self prepareUI];
    
    _adThumbWidthConstraintDefault = _adThumbWidthConstraint.constant;
}

- (void)prepareUI {
    self.backgroundView = [[FLListingCellBackgroundView alloc] init];

    self.adThumbnail.clipsToBounds = NO;
    self.adThumbnail.layer.borderWidth = 2.0f;
    self.adThumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.adThumbnail.layer.shadowColor = [UIColor blackColor].CGColor;
    self.adThumbnail.layer.shadowOpacity = 0.35f;
    self.adThumbnail.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);

    _placeholderImage = [UIImage imageNamed:@"loading30x30"];
    self.adThumbnail.image = _placeholderImage;

    // check in configs this option
    if (![[FLConfig withKey:@"display_photos_count"] intValue]) {
        [self.photosCountView removeFromSuperview];
        self.photosCountView = nil;
    }

    _adPriceLabel.textColor = FLHexColor(kColorThemePrice);
}

#pragma mark - setters

- (void)setFeatured:(BOOL)featured {
    _featured = featured;

    NSString *hexColor = self.featured ? kColorAdCellFeatured : kColorAdCellNormal;
    self.backgroundView.backgroundColor = [UIColor hexColor:hexColor];
}

- (void)setAdTitle:(NSString *)adTitle {
    _adTitle = adTitle;
    _adTitleLabel.text = _adTitle;
}

- (void)setAdSubTitle:(NSString *)adField {
    _adSubTitle = adField;
    _adSubTitleLabel.text = _adSubTitle;
}

- (void)setAdSubTitleColor:(UIColor *)adSubTitleColor {
    _adSubTitleColor = adSubTitleColor;
    _adSubTitleLabel.textColor = adSubTitleColor;
}

- (void)setAdPrice:(NSString *)adPrice {
    _adPrice = adPrice;
    _adPriceLabel.text = _adPrice;
}

- (void)setPhotosCount:(NSInteger)photosCount {
    _photosCount = photosCount;

    if (_photosCountView != nil)
        _photosCountView.count = _photosCount;
}

- (void)fillWithInfoDictionary:(NSDictionary *)info {
    self.adTitle     = FLCleanString(info[@"title"]);
    self.adSubTitle  = FLCleanString(info[@"middle_field"]);
    self.adPrice     = FLCleanString(info[@"price"]);
    self.photosCount = FLTrueInteger(info[@"photos_count"]);
    self.featured    = FLTrueBool(info[@"featured"]);
    self.showImage   = YES;

    NSString *listingThumbnail = FLTrueString(info[@"thumbnail"]);
    NSURL *photoUrl = URLIFY(listingThumbnail);

    if ([listingThumbnail isEqualToString:kListingPhotoDeniedByType]) {
        self.showImage = NO;
    }
    else if ([listingThumbnail isEqualToString:kListingPhotoNotExists] || photoUrl.scheme.length == 0) {
        [self setNoThumbnailImage];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.adThumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:URLIFY(listingThumbnail)]
                                    placeholderImage:_placeholderImage
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 if (image) {
                                                     self.adThumbnail.image =
                                                     [image imageCroppedToFitSize:self.adThumbnail.frame.size];
                                                 }
                                                 else [self setNoThumbnailImage];
                                             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 [self setNoThumbnailImage];
                                             }];
        });
    }
}

- (void)setNoThumbnailImage {
    self.adThumbnail.image = [UIImage imageNamed:@"no_image"];
}

- (void)setShowImage:(BOOL)show {
    _showImage = show;

    _adThumbnail.hidden = !show;
    _photosCountView.hidden = !show;

    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    [_adThumbWidthConstraint setConstant:_showImage ? _adThumbWidthConstraintDefault : _adThumbnail.frame.origin.y];
}

- (void)hideSubTitleIfEmpty {
    if (_adSubTitleLabel.text.length == 0) {
        _adSubTitleHeightConstraint.constant = 0;
    }
}

@end
