//
//  FLPlansLayout.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 7/16/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLPlansLayout.h"

static CGFloat const kMargin = 15.0f;

@implementation FLPlansLayout

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.minimumInteritemSpacing = kMargin;
        self.minimumLineSpacing = kMargin;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    CGFloat itemWidth = self.collectionView.width - self.collectionView.contentInset.left - self.sectionInset.left - self.sectionInset.right - self.collectionView.contentInset.right - 2 * kMargin;
    self.itemSize = CGSizeMake(itemWidth, self.itemSize.height);
}


@end
