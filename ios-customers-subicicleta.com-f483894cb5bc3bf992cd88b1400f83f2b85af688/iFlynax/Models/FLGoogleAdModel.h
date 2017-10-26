//
//  FLGoogleAdModel.h
//  iFlynax
//
//  Created by Alex on 5/2/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FLBannerPosition) {
    FLBannerPositionTop,
    FLBannerPositionBottom
};

typedef NS_ENUM(NSInteger, FLBannerPage) {
    FLBannerPageHome = 1,
    FLBannerPageRecentryAdded,
    FLBannerPageBrowse,
    FLBannerPageFavorites,
    FLBannerPageSearch,
    FLBannerPageAdDetaild,
    FLBannerPageAccountDetails,
    FLBannerPageAccountType,
    FLBannerPageSearchResults,
    FLBannerPageAccountSearchResults,
    FLBannerPageComments
};

@interface FLGoogleAdModel : NSObject
@property (copy,   nonatomic) NSString         *unitID;
@property (assign, nonatomic) CGFloat          height;
@property (assign, nonatomic) FLBannerPosition position;

+ (instancetype)fromDictionary:(NSDictionary *)dict;
@end
