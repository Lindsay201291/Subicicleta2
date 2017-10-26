//
//  FLProfileTableViewCell.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 12/19/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLProfileTableViewCell.h"
#import "FLInfoTileView.h"

static CGFloat const vSpace = 15.0f;
static CGFloat const height = 96.0f;

@implementation FLProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];
}

- (void)setTiles:(NSArray *)tiles {
    _tiles = tiles;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[self.contentView removeAllSubviews];
    CGFloat width = (self.width - 15 * (self.tiles.count + 1)) / self.tiles.count;
    
	for (int i = 0; i < self.tiles.count; i++) {
		FLInfoTileView *tile = self.tiles[i];
		tile.frame = CGRectMake(vSpace * (i + 1) + i * width, 0, width, height);
        [tile setNeedsDisplay];
		[self.contentView addSubview:tile];
	}
}

@end
