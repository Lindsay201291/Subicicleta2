//
//  FLFieldSelectCellContent.m
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldSelectCellContent.h"
#import "FLGraphics.h"

@implementation FLFieldSelectCellContent

- (void)awakeFromNib {
    [self prepareLayerUI];
}

- (void)prepareForInterfaceBuilder {
    [self prepareLayerUI];
}

- (void)prepareLayerUI {
    self.layer.borderWidth   = 1;
    self.layer.borderColor   = FLHexColor(@"919191").CGColor;
    self.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0, 1);
    self.layer.shadowOpacity = .5f;
    self.layer.shadowRadius  = .0f;
    self.layer.masksToBounds = NO;
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    [painter linearGraientWithRect:self.bounds fromColor:FLHexColor(@"DEDEDE")
                           toColor:[UIColor whiteColor]];
}

@end
