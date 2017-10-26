//
//  FLListingViewCell.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 8/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLListingViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *adThumbnail;

@property (nonatomic, getter=isFeatured) BOOL featured;
@property (assign, nonatomic) NSInteger photosCount;
@property (strong, nonatomic) NSString *adTitle;
@property (strong, nonatomic) NSString *adSubTitle;
@property (strong, nonatomic) NSString *adPrice;

@property (strong, nonatomic) UIColor *adSubTitleColor;

// TODO: Idially should have an InfoModel instance as a parameter
- (void)fillWithInfoDictionary:(NSDictionary *)info;

@end
