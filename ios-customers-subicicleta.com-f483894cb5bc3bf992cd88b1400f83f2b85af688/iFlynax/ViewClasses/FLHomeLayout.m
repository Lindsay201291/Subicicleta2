//
//  FLHomeLayout.m
//  iFlynax
//
//  Created by Alex on 10/16/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLHomeLayout.h"

static CGFloat const kItemSpacing = 5.0f;
static CGFloat const kMaxItemSize = 240.0f;

@implementation FLHomeLayout

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.minimumInteritemSpacing = kItemSpacing;
        self.minimumLineSpacing      = kItemSpacing;
    }
    return self;
}

- (void)prepareLayout {
    
	[super prepareLayout];

	CGFloat collectionWidth = self.collectionView.bounds.size.width;
    
    NSInteger spaceNumber = floorf(collectionWidth / kMaxItemSize);
    
    CGFloat itemWidth = (collectionWidth - kItemSpacing * spaceNumber) / (spaceNumber + 1);
    
    if (!IS_RETINA)
        itemWidth = floorf(itemWidth);

    self.itemSize = CGSizeMake(itemWidth, itemWidth);
}

@end
