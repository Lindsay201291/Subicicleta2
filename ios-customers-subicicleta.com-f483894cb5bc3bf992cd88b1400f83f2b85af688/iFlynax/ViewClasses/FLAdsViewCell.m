//
//  FLAdsViewCell.m
//  iFlynax
//
//  Created by Alex on 10/31/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAdsViewCell.h"
#import "FLGraphics.h"

@implementation FLAdsViewCell

- (void)fillWithInfoDictionary:(NSDictionary *)info {
    [super fillWithInfoDictionary:info];
    
    //in favorites handling
    if (info[@"id"] != nil) {
        self.favoriteButton.adId = [info[@"id"] integerValue];
        [self.favoriteButton updateCurrentState];
    }
    
}

@end