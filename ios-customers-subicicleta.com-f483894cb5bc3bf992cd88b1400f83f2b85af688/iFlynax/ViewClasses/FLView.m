//
//  FLView.m
//  iFlynax
//
//  Created by Alex on 9/16/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLView.h"
#import "FLGraphics.h"

@implementation FLView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = FLHexColor(kColorFLViewBackground);
}

- (NSString *)centerLineColorHex {
    if (_centerLineColorHex == nil) {
        _centerLineColorHex = kColorFLViewDefaultCenterLine;
    }
    return _centerLineColorHex;
}

- (NSString *)bottomLineColorHex {
    if (_bottomLineColorHex == nil) {
        _bottomLineColorHex = kColorFLViewDefaultBottomLine;
    }
    return _bottomLineColorHex;
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    CGFloat lw = .5f;

    // center line
    if (self.centerLine) {
        [painter strokeLineFromPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect) - lw)
                             toPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect) - lw)
                           withColor:FLHexColor(self.centerLineColorHex)
                        andLineWidth:lw * 2];
    }

    // bottom line
    [painter strokeLineFromPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - lw)
                         toPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) - lw)
                       withColor:FLHexColor(self.bottomLineColorHex)
                    andLineWidth:lw * 2];
}

@end
