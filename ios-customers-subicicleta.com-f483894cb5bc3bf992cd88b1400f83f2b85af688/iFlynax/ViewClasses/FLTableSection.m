//
//  FLDetailsSection.m
//  iFlynax
//
//  Created by Alex on 6/4/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLTableSection.h"
#import "FLGraphics.h"

static NSString * const kColorSeparatorTop    = @"484848";
static NSString * const kColorSeparatorBottom = @"ffffff";
static NSString * const kColorBackground      = @"9f9f9f";
static CGFloat    const kSeparatorHeight      = 1.0f;

@implementation FLTableSection

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	if (self) {
        self.backgroundView = [UIView new];
    }
	return self;
}

// don't remove this method it calls layer drawing
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
    FLContextPainter *painter = [[FLContextPainter alloc] initWithContext:ctx];
    
    CGFloat bY = layer.bounds.size.height - kSeparatorHeight + 0.5f;
    
    [painter fillRect:layer.bounds withColor:FLHexColor(kColorBackground)];
    
    [painter strokeLineFromPoint:CGPointMake(0, 0.5f)
                         toPoint:CGPointMake(layer.bounds.size.width, 0.5f)
                       withColor:FLHexColor(kColorSeparatorTop)
                    andLineWidth:kSeparatorHeight];
    
    [painter strokeLineFromPoint:CGPointMake(0, bY)
                         toPoint:CGPointMake(layer.bounds.size.width, bY)
                       withColor:FLHexColor(kColorSeparatorBottom)
                    andLineWidth:kSeparatorHeight];
}

@end