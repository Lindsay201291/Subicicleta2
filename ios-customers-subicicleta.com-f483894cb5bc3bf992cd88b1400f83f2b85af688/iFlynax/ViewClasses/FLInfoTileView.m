//
//  FLInfoTileView.m
//  Profile
//
//  Created by Evgeniy Novikov on 11/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLInfoTileView.h"

@implementation FLInfoTileView

static NSString * const viewNidName = @"FLInfoTile";

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:viewNidName owner:self options:nil];
        self.view.frame = self.bounds;
        [self insertSubview:_view atIndex:0];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andInfo:(NSString *)info {
    self = [self init];
    if (self) {
        self.titleLabel.text = title;
        self.infoLabel.text  = info;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

- (void)drawRect:(CGRect)rect {
    UIColor *frameBgColor = [UIColor colorWithRed:.72 green:.72 blue:.72 alpha:1];
    UIColor *contentBgColor = [UIColor colorWithRed:.83 green:.83 blue:.83 alpha:1];

    CGContextRef context = UIGraphicsGetCurrentContext();

    //Frame
    CGContextSetFillColorWithColor(context, frameBgColor.CGColor);
    CGContextFillRect(context, rect);

    //Content box
    CGContextSetFillColorWithColor(context, contentBgColor.CGColor);
    CGContextFillRect(context, CGRectMake(2, 32, rect.size.width - 4, rect.size.height - 34));
}

@end
