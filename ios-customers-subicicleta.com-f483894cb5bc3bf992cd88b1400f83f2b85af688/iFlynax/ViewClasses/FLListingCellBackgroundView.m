//
//  FLAdsCellBgView.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 7/29/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingCellBackgroundView.h"
#import "FLGraphics.h"

static NSString * const kColorAdCellTopLine     = @"ffffff";
static NSString * const kColorAdCellBottomLine  = @"aaaaaa";
static CGFloat    const kAdCellSeparatorHeight  = 1.0f;

@implementation FLListingCellBackgroundView

- (void)drawRect:(CGRect)rect {
    
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    
    //top edge line
    [painter strokeLineFromPoint:CGPointMake(0, 0)
                         toPoint:CGPointMake(self.bounds.size.width, 0)
                       withColor:[UIColor hexColor:kColorAdCellTopLine]
                    andLineWidth:kAdCellSeparatorHeight];
    
    //bottom edge line
    [painter strokeLineFromPoint:CGPointMake(0, self.bounds.size.height)
                         toPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)
                       withColor:[UIColor hexColor:kColorAdCellBottomLine]
                    andLineWidth:kAdCellSeparatorHeight];
}

@end
