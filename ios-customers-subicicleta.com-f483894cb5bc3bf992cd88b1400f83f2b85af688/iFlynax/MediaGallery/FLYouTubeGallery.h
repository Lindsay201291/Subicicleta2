//
//  FLYouTubeGallery.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLMediaGallery.h"
#import "FLYouTubeMGItemModel.h"

@interface FLYouTubeGallery : FLMediaGallery

- (void)loadFromArray:(NSArray *)items;

@end
