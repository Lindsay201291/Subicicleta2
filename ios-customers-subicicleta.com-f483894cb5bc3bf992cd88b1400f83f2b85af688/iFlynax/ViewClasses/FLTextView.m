//
//  FLTextView.m
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTextView.h"
#import "FLGraphics.h"

static CGFloat const kContentInset = 5;

@implementation FLTextView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self prepareLayerUI];
}

- (void)prepareLayerUI {
    self.textContainerInset  = UIEdgeInsetsMake(kContentInset, kContentInset, kContentInset, kContentInset);
    self.layer.borderWidth   = 1;
    self.layer.borderColor   = FLHexColor(@"919191").CGColor;
    self.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0, 1);
    self.layer.shadowOpacity = .5f;
    self.layer.shadowRadius  = .0f;
    self.layer.masksToBounds = YES;
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    [painter linearGraientWithRect:self.bounds fromColor:FLHexColor(@"DEDEDE")
                           toColor:[UIColor whiteColor]];
}

@end
